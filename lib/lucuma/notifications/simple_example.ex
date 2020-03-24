defmodule Notifications.SimpleExample do
  # start_link is just a name common method name for spawning
  # a process.
  def start_link do
    # spawn_link allows us to spawn a new process linked to the current process.
    # This means that if an error occurs in the new process it will propagate to
    # the current process where it can be handled.
    # When the new process fails it will send the current process an exit signal.
    #
    # __MODULE__ is a macro that evaluates to this module's name.
    # :loop is the function that process will run
    # [] is the list of arguments to the loop function. It consists of an empty map.
    spawn_link(__MODULE__, :loop, [%{}])
  end

  # state is the arguments passed in the start_link/spawn_link function above.
  # In this case state is %{} because there is only one argument and one element in the list above.
  def loop(state) do
    # receive allows this process to receive messages from others.
    # When a message is sent to this prociess, the message is stored in the mailbox. The receive function
    # goes through the mailbox searching for a message that matches certain paterns.
    receive do
      # When receive matches this pattern it parse it, adds it to the new state, and then calls loop again
      # with the new state. It goes back to the start searches the mailbox again or waits if it's empty.
      # Without calling loop it would just finish and die.
      {:add, item} ->
        {key, value} = item
        new_state = Map.put(state, key, value)
        loop(new_state)

      {:remove, key} ->
        new_state = Map.delete(state, key)
        loop(new_state)

      {:state, from} ->
        IO.inspect(state)
        # This sends a message to the pid 'from'
        # Unless it has a receieve block it will just sit in the process's mailbox
        # You can use `flush` to see whats in the mailbox.
        send(from, state)
        loop(state)

      # This is a catch all to catch anything that does match.
      # You could raise an error in here.
      _ ->
        IO.inspect("Nothing matched. Raising error")
    end
  end
end
