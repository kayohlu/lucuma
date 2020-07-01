defmodule Lucuma.Notifications.V4.NotificationConsumer do
  use GenStage

  require Logger

  alias Lucuma.Notifications
  alias Lucuma.Notifications.Notifier

  @max_demand 100
  @min_demand 99

  # client

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, %{})
  end

  # server

  def init(_) do
    Process.flag(:trap_exit, true)

    {
      :consumer,
      %{event_count: 0, monitored_processes: %{}, subscribed_producer: nil},
      subscribe_to: [
        {Lucuma.Notifications.V4.NotificationBroadcaster,
         min_demand: @min_demand, max_demand: @max_demand}
      ]
    }
  end

  def handle_subscribe(producer, subscription_options, from_producer, state) do
    max_demand = Keyword.get(subscription_options, :max_demand, @max_demand)

    GenStage.ask(from_producer, max_demand)

    {:manual, Map.put(state, :subscribed_producer, from_producer)}
  end

  def handle_events(events, from_producer, state) do
    Logger.info("#{__MODULE__} Handling #{length(events)} events from producer")
    IO.inspect(state)

    updated_state =
      state
      |> Map.update!(:event_count, &(&1 + length(events)))
      |> consume_events(events)

    IO.inspect(updated_state)

    {:noreply, [], updated_state}
  end

  def try_ask(state) do
    IO.puts("trying to ask")
    IO.inspect(state)
    IO.inspect(state.event_count)
    IO.inspect(state.event_count <= @min_demand)
    # 1. Only ask when event_count is less than minimum demand
    if state.event_count <= @min_demand do
      # 2. how much to ask
      GenStage.ask(state.subscribed_producer, @max_demand - state.event_count)
    else
      :ok
    end
  end

  @doc """
  This is a successful message..
  """
  def handle_info({:DOWN, task_ref, :process, from, :normal}, state) do
    Logger.info("#{__MODULE__} Notifier process #{inspect(from)} :DOWN for :normal reason")
    IO.inspect(task_ref)
    IO.inspect(state)

    Process.demonitor(task_ref, [:flush])

    state = Map.update!(state, :event_count, &(&1 - 1))
    {_, state} = pop_in(state, [:monitored_processes, task_ref])

    IO.inspect(state)
    x = try_ask(state)
    IO.puts("asfter asking")
    IO.inspect(state)

    {:noreply, [], state}
  end

  @doc """
  Since this process monitors the notifier processes, when they receive a shutdown
  exit signal they send the message below to this process.
  We handle it here.
  """
  def handle_info({:DOWN, task_ref, :process, from, :shutdown}, state) do
    Logger.info("#{__MODULE__} Notifier process #{inspect(from)} received a shut down signal")
    {:noreply, [], state}
  end

  @doc """
  The task completed unsuccessfully.
  Some exception was raised because of `reason`.
  Process crashed?
  We change the status to "for_delivery" so sending can be retried.
  """
  def handle_info({:DOWN, task_ref, :process, from, reason}, state) do
    Logger.info(
      "#{__MODULE__} Notifier process #{inspect(from)} failed because: #{inspect(reason)}"
    )

    state
    |> Map.get(task_ref)
    |> Lucuma.Notifications.Notifier.mark_notification_for_delivery()

    state = Map.update!(state, :event_count, &(&1 - 1))
    {_, state} = pop_in(state, [:monitored_processes, task_ref])

    try_ask(state)

    {:noreply, [], state}
  end

  def consume_events(state, events) do
    IO.puts("#{__MODULE__} consume events")

    state =
      Enum.reduce(events, state, fn event, state_acc ->
        result = consume_event(event)
        {ref, event} = result

        state_acc
        |> put_in([:monitored_processes, Access.key(ref, %{})], event)
      end)

    IO.puts("#{__MODULE__} state: #{inspect(state)}")

    state
  end

  @doc """
  In this function I use the dynamic supervisor to add the notifier tasks
  to the app's supervision tree because when a shutdown signal is sent I want the
  tasks to gracefully shut down.
  I want them to gracefully shut down because they might be in the middle of processing
  a notification and I want the processing to complete successfully, or if something
  goes wrong, mark the notification to be sent again.

  This process monitors the notifier tasks too so that they can me marked as completed
  or not and handled appropriately.
  """
  defp consume_event(event) do
    {:ok, child_pid} =
      DynamicSupervisor.start_child(
        Lucuma.NotifierDynamicSupervisor,
        {Lucuma.Notifications.NotifierTask, event}
      )

    # Monitor the process so this process is notified of failures in the
    # NotifierTask
    monitor_reference = Process.monitor(child_pid)

    Logger.info(
      "#{__MODULE__} Notifier process now monitored by #{__MODULE__} #{inspect(self())} for event ID: #{
        event.id
      }"
    )

    {monitor_reference, event}
  end

  def terminate(reason, state) do
    Logger.info("#{__MODULE__} terminating. Reason: #{inspect(reason)}")
  end
end
