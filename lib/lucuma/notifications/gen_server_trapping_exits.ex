defmodule Notifications.GenServerTrappingExits do
  # Use Genserver
  use GenServer

  def start_link do
    # Note that a GenServer started with start_link/3 is linked to the
    # parent process and will exit in case of crashes from the parent.
    # The GenServer will also exit due to the :normal reasons in case it is
    # configured to trap exits in the init/1 callback.
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add(pid, item) do
    GenServer.cast(pid, {:add, item})
  end

  def remove(pid, key) do
    GenServer.call(pid, {:remove, key})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def init(:ok) do
    # For a process to exit gracefully it needs to trap exits.
    # A process does not trap exits by default.
    Process.flag(:trap_exit, true)
    {:ok, %{}}
  end

  def handle_cast({:add, item}, state) do
    {key, value} = item
    new_state = Map.put(state, key, value)
    {:noreply, new_state}
  end

  def handle_call({:remove, key}, _from, state) do
    new_state = Map.delete(state, key)
    {:reply, new_state, new_state}
  end

  # In this call here we're just passing an atom as a message.
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def terminate(reason, state) do
    # If the GenServer receives an exit signal that is not :normal from any
    # process when it is not trapping exits it will exit abruptly with the same
    # reason and so not call terminate/2.
    #
    # Invoked when an EXIT signal is sent to the server.
    # Any cleanup of the process should be done in this callback.
    # terminate/2 is called if a callback other than init/1 does one of the following:
    # - returns a :stop tuple
    # - raises
    # - calls Kernel.exit/1
    # - returns an invalid value
    # - the GenServer traps exits (using Process.flag/2) and the parent process
    #   sends an exit signal
    IO.puts("Terminating GenServer process.")
  end
end
