defmodule HoldUp.Notifications.ExampleProducer do
  use GenStage

  @moduledoc """
  This module is a producer
  It handles demand for events from consumers or producer/consumers.
  It responds with what is being demanded.
  Once demand arrives, the producer will emit items, never emitting more items
  than the consumer asks for. This provides a back-pressure mechanism.
  Back pressure just means that events queue up in the producer not affecting
  the consumer in any way.
  """

  # client

  def start_link(initial_counter_value) do
    GenStage.start_link(__MODULE__, initial_counter_value, name: __MODULE__)
  end

  # server

  @doc """
  The init callback must return a tuple where the first element is :producer
  The argument to init is the initial state which is passed by start_link above.
  The second element to the returned tuple is the initial state. In this case the
  counter value passed in the function argument.
  """
  def init(counter) do
    {:producer, counter}
  end

  @doc """
  The handle_demand function is invoked when demand is placed from a consumer or
  a consumer/dispatcher.
  """
  def handle_demand(demand, state) do
    IO.puts("Current producer state: #{state}")
    IO.puts("Producer demand: #{demand}")

    # Events seem to be a term for the things that will be returned to the demander..
    # The could by anything really..
    events = Enum.to_list(state..(state + demand))
    IO.inspect(events)
    {:noreply, events, demand + state}
  end
end
