defmodule Lucuma.Notifications.NotifierTask do
  @moduledoc """
  Very helpful information: https://stackoverflow.com/questions/39756769/graceful-shutdown-of-genserver
  """
  require Logger
  # if it raises an error the consumer will cleanup.
  use GenServer, restart: :temporary
  alias Lucuma.Notifications.Notifier

  def start_link(event) do
    GenServer.start_link(__MODULE__, event, [])
  end

  def init(event) do
    Process.flag(:trap_exit, true)

    send_notification(self(), event)

    {:ok, %{sent: false, event: event}}
  end

  defp send_notification(pid, event) do
    GenServer.cast(pid, {:send_notification, event})
  end

  def handle_cast({:send_notification, event}, state) do
    Logger.info("#{__MODULE__} handling message to send sms")

    Notifier.send_notification(event)

    Logger.info("#{__MODULE__} sms sent sending exit signal to self")

    Process.exit(self(), :normal)

    {:noreply, %{sent: true, event: event}}
  end

  @doc """
  Since this GenServer is trapping exits and is sending an exit
  signal to itself (because it's job is finished), the exit signal will
  be transformed into the message {:EXIT, from, reason} which we'll handle
  here.
  """
  def handle_info({:EXIT, from, :normal}, state) do
    Logger.info(
      "#{__MODULE__} GenServer #{inspect(self())} receive exit signal for normal reasons from #{
        inspect(from)
      }"
    )

    Logger.info(
      "#{__MODULE__} GenServer #{inspect(self())} state after exit signal received: #{
        inspect(state.sent)
      }"
    )

    # Since we've been told to exit for reason normal, and nothing went wrong,
    # we want to stop the process
    {:stop, :normal, state}
  end

  def terminate(reason, state) do
    Logger.info(
      "#{__MODULE__} GenServer #{inspect(self())} terminating because reason: #{reason} state: #{
        inspect(state.sent)
      }"
    )

    if %{sent: true, event: event} = state do
      Logger.info(
        "#{__MODULE__} GenServer #{inspect(self())} sent the notification request. no need to clean up."
      )
    else
      Logger.info(
        "#{__MODULE__} GenServer #{inspect(self())} did not send the notification request. clean up."
      )

      Notifier.mark_notification_for_delivery(event)

      Logger.info("#{__MODULE__} GenServer #{inspect(self())} cleaned up.")
    end
  end
end
