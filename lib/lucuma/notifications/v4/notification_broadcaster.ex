defmodule Lucuma.Notifications.V4.NotificationBroadcaster do
  use GenStage
  require Logger

  alias Lucuma.Notifications

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def async_notify() do
    GenStage.cast(__MODULE__, :notify)
  end

  @doc """
  The BroadcastDispatcher is a dispatcher that accumulates demand from all
  consumers before broadcasting events to all of them.

  The GenStage.BroadcastDispatcher will guarantee events are dispatched to all consumers
  in a way that does not exceed the demand of any of the consumers.

  I think..
  This is important because since we are not in control of the source of the data i.e.
  we cannot guarantee how many events will arrive, nor if there will be any.
  So when events arrive we need to make sure we don't overload any consumer when
  a lot of events are being dispatched.

  We are not demand driven in this scenario, data comes in from an external source,
  it is not requested.

  One important thing to remember is that the BroadcastDispatcher only sends enough
  events to each consumer such that they wont ever get more than they need, but if
  you have a consumer which spawns processes to handle the events, your consumer
  will effectively always be available for events as soon as those processes
  are  spawned, and we loose the ability to apply back pressure.
  A consumer is only busy as long as it's handle_events callback is working away..
  """
  def init(:ok) do
    Process.flag(:trap_exit, true)

    {:producer, {:queue.new(), 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_subscribe(consumer, subscription_options, from, state) do
    IO.puts("#{__MODULE__} handle subscribe from: #{consumer}")
    IO.inspect(subscription_options)
    IO.inspect(state)

    {:automatic, state}
  end

  @doc """
  If the number of events returned by `dispatch_events` exceeds the amount
  of demand the consumers can handle, the new events will be placed in
  GenStage's internal buffer.

  In this version when the notify message is recieved it's because a new notifcation
  must be sent. I pull one notifcation for dispatch from the DB and add it to
  the producer's queue.
  """
  def handle_cast(:notify, {queue, pending_demand} = state) do
    IO.puts("#{__MODULE__} handling the message sent to the broadcaster, :notify")
    IO.puts("#{__MODULE__} state #{inspect(state)}")

    updated_queue =
      get_events(1)
      |> queue_events(queue)

    dispatch_events(updated_queue, pending_demand, [])
  end

  @doc """
  Even though we are using a broadcast dispatcher, the consumer could still demand
  events.

  When can this happen?
  - When the consumer process starts.
  - When there are no more "broadcasted" events coming in.
  - When there are no more "broadcasted" events and the GenStage internal buffer is empty.

  This is good because there are situations where events will need to be
  handled again, and they wont be "broadcasted" by the broadcaster.
  For example, if a notification fails to send because some exception was raised
  and needs to be sent again.

  Since we have notifications that need to be handled again, and they are marked
  for disaptch, we query the db for more notifications that need to be dispatched
  but limit the amount returned based on the incoming demand from the consumer.
  """
  def handle_demand(incoming_demand, {queue, pending_demand} = state) do
    IO.puts("#{__MODULE__} handling demand from consumer")
    IO.puts("#{__MODULE__} Current producer state: #{inspect(state)}")
    IO.puts("#{__MODULE__} Consumer demand: #{incoming_demand}")

    updated_queue =
      get_events(incoming_demand)
      |> queue_events(queue)

    dispatch_events(updated_queue, incoming_demand + pending_demand, [])
  end

  @doc """
  This function gets called when demand is 0.
  This means we have built up the list of events to dispatch to our consumers, or
  there is 0 demand and no events ([]) to dispatch.
  """
  defp dispatch_events(queue, 0 = pending_demand, events) do
    IO.puts("#{__MODULE__} dispatch_events to consumer since pending_demand is gone down to zero")

    {:noreply, Enum.reverse(events), {queue, 0}}
  end

  @doc """
  This function is called when the pending_demand value is > 0.
  Here we try to remove items from the queue until it's empty or the number
  of events removed from the queue reduces the pending_demand value to 0
  """
  defp dispatch_events(queue, pending_demand, events) do
    IO.puts("#{__MODULE__} dispatch_events current queue:")
    IO.inspect(queue)
    IO.puts("==============")

    case :queue.out(queue) do
      {{:value, event}, queue} ->
        IO.puts("#{__MODULE__} dispatch_events populate events to send and reduce pending_demand")
        IO.puts("#{__MODULE__} new pending_demand #{pending_demand - 1}")
        IO.puts("#{__MODULE__} new events #{inspect([event | events])}")

        dispatch_events(queue, pending_demand - 1, [event | events])

      {:empty, queue} ->
        IO.puts("#{__MODULE__} dispatch_events the queue is empty, send to consumer anyway")

        {:noreply, Enum.reverse(events), {queue, pending_demand}}
    end
  end

  defp queue_events(events, queue) do
    case events do
      [] -> queue
      _ -> Enum.reduce(events, queue, &:queue.in(&1, &2))
    end
  end

  # Hack to get around the producer doing a query in the test environment when
  # the test process is finished and the repo process.
  defp get_events(limit), do: get_events(Mix.env(), limit)
  defp get_events(:test, _limit), do: []
  defp get_events(_, limit), do: Notifications.notifications_for_dispatch(limit)

  def terminate(reason, state) do
    Logger.info("#{__MODULE__} terminating. Reason: #{inspect(reason)}")
    Logger.info("Cleaning up broadcaster queue")
  end
end
