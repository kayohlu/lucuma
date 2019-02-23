defmodule Notifications.GenServerExample do
  # Use Genserver
  use GenServer

  # Client

  # start_link is just a name common method name for spawning
  # a process.
  def start_link do
    # spawn_link allows us to spawn a new process linked to the current process.
    # This means that if an error occurs in the new process it will propagate to
    # the current process where it can be handled.
    # When the new process fails with will send the current process an exit signal.
    #
    # __MODULE__ is a macro that evaluates to this module's name.
    # :loop is the function that process will run
    # [] is the list of arguments to the loop function. It consists of an empty map.
    GenServer.start_link(__MODULE__, :ok, [])
  end

  # This is a client function that sends an asynchronous message (via cast) to the server
  # that will add the new item to the state.
  # Using case means that server wont send a reply and the client wont wait for one.
  # pid is the server pid
  # The second param is the message being sent.
  def add(pid, item) do
    GenServer.cast(pid, {:add, item})
  end

  # This is a client function that sends a synchronous message (via call) to the server
  # that will remove an item from the state.
  # pid is the server pid
  # The second param is the message being sent.
  def remove(pid, key) do
    GenServer.call(pid, {:remove, key})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  # GenServer callbacks i.e. the server
  # These are the callbacks that are used to handle messages being sent to the GenServer
  # process.

  # When we call `start_link` above it goes back to GenServer module and looks for this
  # init function below where we define out initial state..
  def init(:ok) do
    {:ok, %{}}
  end

  # `handle_cast` will handle the message, update the state accordingly and return a tuple
  # that tells the GenServer not to send reply and update the state with the new state.
  def handle_cast({:add, item}, state) do
    {key, value} = item
    new_state = Map.put(state, key, value)
    # We use no reply here because we are telling GenServer not to reply AND save the state.
    {:noreply, new_state}
  end

  # `handle_call` will handle the message, update the state accordingly and return a tuple
  # that tells the GenServer to reply with some information for the client,
  # and update the state with the new state.
  def handle_call({:remove, key}, _from, state) do
    new_state = Map.delete(state, key)

    # The return from this function is important.
    # The first value is the reply atom which tells GenServer to reply to the client
    # with the second value.
    # The third values is the state we want to save in the process. IMPORTANT: This would be the entire state.
    {:reply, new_state, new_state}
  end

  # In this call here we're just passing an atom as a message.
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end

defmodule Notifications.NamedGenServerExample do
  # Use Genserver
  use GenServer

  # The name macro lets you create a "module variable" which is accessable
  # throughout the module.
  # In this case it's the name of the module.
  @name __MODULE__

  # Client

  def start_link do
    # We name our gen server here.
    # the last param could also be written without the square brackets around it.
    GenServer.start_link(__MODULE__, :ok, [name: @name])
  end

  # We don't need to pass in the pid anymore because the process is named now.
  # We just pass the name of the process as the first argument to cast.
  def add(item) do
    GenServer.cast(@name, {:add, item})
  end

  # We don't need to pass in the pid anymore because the process is named now.
  # We just pass the name of the process as the first argument to call.
  def remove(key) do
    GenServer.call(@name, {:remove, key})
  end

  # We don't need to pass in the pid anymore because the process is named now.
  # We just pass the name of the process as the first argument to call.
  def state do
    GenServer.call(@name, :state)
  end

  # GenServer callbacks i.e. the server

  def init(:ok) do
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

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
end
