defmodule HoldUp.Notifications.ExampleConsumer do
  use GenStage

  @moduledoc """
  This module is a consumer
  It does not produce events. Events are just the things that are being demanded.
  It only generates demand for events and handles them.
  It is a process which subscribes to a producer or producer/consumer.
  """

  # client

  def start_link do
    GenStage.start_link(__MODULE__, :ok)
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
  """
  def init(state) do
    IO.puts "Initial consumer state"
    IO.inspect state
    {:consumer, state, subscribe_to: [{HoldUp.Notifications.Producer, min_demand: 1, max_demand: 2}]}
  end

  def handle_events(events, from, state) do
    IO.puts "Handling events from producer"
    for event <- events do
      IO.inspect {"Consumer", self, "received event: #{event} from pid", from}
    end

    {:noreply, [], state}
  end
end