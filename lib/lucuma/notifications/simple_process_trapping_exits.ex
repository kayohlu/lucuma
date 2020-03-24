defmodule Notifications.SimpleProcessTrappingExits do
  def start_link do
    x = spawn_link(__MODULE__, :loop, [%{}])
    Process.send_after(x, {:ping}, 1000)
    x
  end

  def loop(state) do
    # For a process to exit gracefully it needs to trap exits.
    # A process does not trap exits by default.
    # How a process exits:
    # if reason not in [:normal, :kill]
    #   if trapping_exits?
    #     exit signal is transformed into a message
    #     {:EXIT, from, reason}
    #     and delivered to the message queue of the process.
    #
    #   else
    #     process will exit straight away with the given reason.
    #   end
    # elsif reason == :normal
    #   if this process tells itself to exit
    #     if trapping_exits?
    #       exit signal is transformed into a message
    #       {:EXIT, from, reason}
    #       and delivered to the message queue of the process.
    #
    #     else
    #       process will exit straight away with the given reason.
    #     end
    #   else
    #    this process wont exit
    #   end
    # elsif reason == :kill
    #   if trapping_exits?
    #     an untrappable exit signal is sent to pid which will unconditionally
    #     exit with reason :killed.
    #   else
    #     an untrappable exit signal is sent to pid which will unconditionally
    #     exit with reason :killed.
    #   end
    # else
    #   if trapping_exits?
    #     exit signal is transformed into a message
    #     {:EXIT, from, reason}
    #     and delivered to the message queue of the process.
    #   else
    #     the process exits with the reason
    #   end
    # end

    Process.flag(:trap_exit, true)

    IO.puts("I'm alive")

    receive do
      {:ping} ->
        IO.puts("Ping")
        Process.send_after(self(), {:ping}, 1000)
        loop(state)

      {:EXIT, from, reason} ->
        IO.puts("Received EXIT from #{inspect(from)} with reason: #{inspect(reason)}")
        IO.puts("calling terminate")
        terminate(state)

      _ ->
        IO.inspect("Nothing matched. Raising error")
    end
  end

  def terminate(state) do
    IO.puts("terminating")
  end
end
