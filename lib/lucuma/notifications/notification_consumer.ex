defmodule Lucuma.Notifications.NotificationConsumer do
  use GenStage

  require Logger

  alias Lucuma.Notifications
  alias Lucuma.Notifications.Notifier

  @moduledoc """
  This module is a consumer
  It does not produce events. Events are just the things that are being demanded.
  It only generates demand for events and handles them.
  It is a process which subscribes to a producer or producer_consumer.
  """

  # client

  def start_link(opts) do
    GenStage.start_link(__MODULE__, %{})
  end

  # server

  @doc """
  The init callback returns a tuple where the first element must be :consumer
  The second is the consumer's state. In this example it's :ok, because that's what we passed in the
  start_link function above.
  The third element is a keyword list of options. Here, one of the options is the producer we want to
  subscribe to.

  A consumer and producer_consumers send demand in batches. In other words it asks
  for a bunch of things in one go. This can be controlled with min_demand and
  max_demand options. See below..

  IMPORTANT:
  The :max_demand specifies the maximum amount of events that must be in flow while the :min_demand specifies the
  minimum threshold to trigger for more demand.
  For example, if :max_demand is 1000 and :min_demand is 750, the consumer will ask for 1000 events initially and
  ask for more only after it receives at least 250.

  How does the consumer know when to demand more?
  It starts processing the events as soon as it gets them from the producer or producer_consumer, and as soon as the
  amount of events left reaches the min_demand, the consumer demands more.

  I think... The consumer subtracts the number of events/things it receives from the max_demand amount and if it's
  less than or equal to the min_demand amount, it demands more..
  Subsequent demand is only placed when: (max_demand - length(events)) < min_demand

  # Having min_demand: 0, max_demand: 1 seems to demand one thing at a time from the producer.
  """
  def init(state) do
    Process.flag(:trap_exit, true)

    {:consumer, state,
     subscribe_to: [{Lucuma.Notifications.NotificationProducer, min_demand: 50, max_demand: 100}]}
  end

  def handle_events(events, from, state) do
    Logger.info("#{__MODULE__} Handling #{length(events)} events from producer")

    new_state =
      Enum.into(events, state, fn event ->
        result = process_event(event)
        {ref, event} = result
      end)

    {:noreply, [], new_state}
  end

  @doc """
  This is a successful message.
  if we don't care about the DOWN message now, we can demonitor and flush it.
  If we do not demonitor the DOWN message will be sent.
  """
  def handle_info({task_ref, result}, state) do
    Logger.info(
      "#{__MODULE__} Notifier process completed successfully #{inspect({task_ref, result})}"
    )

    # Process.demonitor(task_ref, [:flush])
    {:noreply, [], Map.delete(state, task_ref)}
  end

  @doc """
  This handle_info callback is defined because even though handle_info({ref, result}, state) above is invoked
  another message is sent to this process and it's handled by this function.
  If we use `Process.demonitor(ref, [:flush])` in `handle_info({ref, result}, state)` this callback won't be invoked.
  This is a successful message..
  """
  def handle_info({:DOWN, task_ref, :process, from, :normal}, state) do
    Logger.info("#{__MODULE__} Notifier process #{inspect(from)} :DOWN for :normal reason")
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
  Some exception was raised and you'll see it in `reason`.
  Process crashed?
  We change the status to "for_delivery" so sending can be retried.
  """
  def handle_info({:DOWN, task_ref, :process, from, reason}, state) do
    Logger.info(
      "#{__MODULE__} Notifier process #{inspect(from)} failed because: #{inspect(reason)}"
    )

    # Notifications.update_sms_notification(Map.get(state, task_ref), %{status: "for_delivery"})

    Map.get(state, task_ref)
    |> Lucuma.Notifications.Notifier.mark_notification_for_delivery()

    {:noreply, [], Map.delete(state, task_ref)}
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
  defp process_event(event) do
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
