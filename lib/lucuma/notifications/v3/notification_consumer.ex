defmodule Lucuma.Notifications.V3.NotificationConsumer do
  @moduledoc """
  This consumer is a conusmer supervisor.
  """

  use ConsumerSupervisor

  alias Lucuma.Notifications.V4.NotificationBroadcaster
  alias Lucuma.Notifications.NotifierTask

  # client

  def start_link(_opts) do
    ConsumerSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # server

  @doc """
  Once subscribed, the supervisor will ask the producer for :max_demand events
  and start child processes as events arrive. As child processes terminate, the
  supervisor will accumulate demand and request more events once :min_demand is
  reached. This allows the ConsumerSupervisor to work similar to a pool, except
  that a child process is started per event. The minimum amount of concurrent children
  per producer is specified by :min_demand and the maximum is given by :max_demand.

  Important
  Since this is a Supervisor process now usually if a child process dies the supervisor
  would die too unless it's trapping exists (which it doesn't right now).
  Below we set the restart strategy to :temporary. This means that the
  child process is never restarted, regardless of the supervision strategy: any
  termination (even abnormal) is considered successful.
  For example, if a child process dies because an exception is raised, this
  process will not die.
  NOTE: Right now, I'm not sure if the child process sends a message to this
  provess when it dies or if does this supervisor just ignores it somehow..
  """
  def init(:ok) do
    # Note: By default the restart for a child is set to :permanent
    # which is not supported in ConsumerSupervisor. You need to explicitly
    # set the :restart option either to :temporary or :transient.
    children = [%{id: NotifierTask, start: {NotifierTask, :start_link, []}, restart: :temporary}]

    opts = [
      strategy: :one_for_one,
      subscribe_to: [{NotificationBroadcaster, min_demand: 2, max_demand: 4}]
    ]

    ConsumerSupervisor.init(children, opts)
  end

  def handle_subscribe(producer, subscription_options, from, state) do
    IO.puts("#{__MODULE__} handle subscription")
    IO.puts("#{__MODULE__} subscribed to #{producer}")
    IO.inspect(subscription_options)
    IO.inspect(state)

    {:automatic, state}
  end

  def handle_info(msg, state) do
    IO.puts("#{__MODULE__} hadle info: ")
    IO.inspect(msg)
  end
end
