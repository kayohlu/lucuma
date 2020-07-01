defmodule Lucuma.Notifications.V2.NotificationBroadcaster do
  use GenStage
  require Logger

  alias Lucuma.Notifications

  def start_link(:ok) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def async_notify() do
    GenStage.cast(__MODULE__, {:notify})
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

  Here we dispatch events as soon as they arrive
  By always sending events as soon as they arrive, if there is any demand, we
  will serve the existing demand, otherwise the event will be queued in GenStage's
  internal buffer. In case events are being queued and not being consumed, a
  log message will be emitted when we exceed the :buffer_size configuration.
  """
  def init(:ok) do
    Process.flag(:trap_exit, true)

    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  @doc """
  Query for the events and dispatch immediately.

  If the number of events returned by `dispatch_events` exceeds the amount
  of demand the consumers can handle, the new events will be placed in
  GenStage's internal buffer.

  It's important to note that the number of events returned by `dispatch_events`
  could potentially exceed the size of GenStage's internal buffer and be
  dropped.

  See:
  https://hexdocs.pm/gen_stage/GenStage.html#module-buffering-events
  https://hexdocs.pm/gen_stage/GenStage.html#c:init/1-producer-and-producer_consumer-options
  """
  def handle_cast({:notify}, state) do
    IO.puts("#{__MODULE__} handling the message sent to the broadcaster, :notify")
    IO.puts("#{__MODULE__} state #{state}")

    {:noreply, dispatch_events, state}
  end

  def handle_subscribe(consumer, subscription_options, from, state) do
    IO.puts("#{__MODULE__} handle subscribe from: #{consumer}")
    IO.inspect(subscription_options)
    IO.inspect(state)

    {:automatic, state}
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

  If the number of events returned by `dispatch_events` exceeds the amount
  of demand the consumers can handle, the new events will be placed in
  GenStage's internal buffer.

  It's important to note that the number of events returned by `dispatch_events`
  could potentially exceed the size of GenStage's internal buffer and be
  dropped.

  See:
  https://hexdocs.pm/gen_stage/GenStage.html#module-buffering-events
  https://hexdocs.pm/gen_stage/GenStage.html#c:init/1-producer-and-producer_consumer-options

  """
  def handle_demand(incoming_demand, state) do
    IO.puts("#{__MODULE__} handling demand from consumer")
    IO.puts("#{__MODULE__} Current producer state: #{inspect(state)}")
    IO.puts("#{__MODULE__} Consumer demand: #{incoming_demand}")

    # We don't care about the demand
    {:noreply, dispatch_events, state}
  end

  # Hack to get around the producer doing a query in the test environment when
  # the test process is finished and the repo process.
  defp dispatch_events(), do: dispatch_events(Mix.env())
  defp dispatch_events(:test), do: []
  defp dispatch_events(_), do: Notifications.notifications_for_dispatch()

  def terminate(reason, state) do
    Logger.info("#{__MODULE__} terminating. Reason: #{inspect(reason)}")
  end
end
