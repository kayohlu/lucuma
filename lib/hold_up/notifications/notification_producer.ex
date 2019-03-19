defmodule HoldUp.Notifications.NotificationProducer do
  use GenStage

  import Ecto.Query

  alias HoldUp.Notifications.Notifier
  alias HoldUp.Repo
  alias HoldUpWeb.Waitlists
  alias HoldUp.Notifications.SmsNotification

  @moduledoc """
  See for help: https://www.youtube.com/watch?v=aZuY5-2lwW4
  This module is a producer
  It handles demand for events from consumers or producer/consumers.
  It responds with what is being demanded.
  Once demand arrives, the producer will emit items, never emitting more items
  than the consumer asks for. This provides a back-pressure mechanism.
  Back pressure just means that events queue up in the producer not affecting
  the consumer in any way.
  """

  # client

  def start_link(initial_state) do
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def send_sms_async do
    GenStage.cast(__MODULE__, {:send_sms_async})
  end

  # server

  @doc """
  The init callback must return a tuple where the first element is :producer
  The argument to init is the initial state which is passed by start_link above.
  The second element to the returned tuple is the initial state. In this case the
  state value passed in the function argument.
  """
  def init(initial_state) do
    {:producer, initial_state}
  end

  @doc """
  The handle_demand function is invoked when demand is placed from a consumer or
  a consumer/dispatcher.
  """
  def handle_demand(demand, state) do
    IO.puts("Producer state: #{state}")
    IO.puts("Producer demand: #{demand}")

    {:noreply, events, demand}
  end

  def handle_cast({:send_sms_async}, state) do
    IO.puts("Handling cast message send_sms_async")

    {:noreply, events, state}
  end

  # Hack to get around the producer doing a query in the test environment when
  # the test process is finished and the repo process.
  defp events, do: events(Mix.env)
  defp events(:test), do: []
  defp events(_), do: enqueue_notifications

  @doc """
  The lock line below allows us to lock those records so another machine running the same process
  cannot query for the same rows in the db resulting in the same sms_notfications being processed more than once.
  The "FOR UPDATE SKIP LOCKED" allows us to "skip" the lock when updating said locked records.
  """
  def enqueue_notifications do
    {:ok, results} =
      Repo.transaction(fn ->
        for_delivery_ids =
          Repo.all(
            from sms in SmsNotification,
              where: sms.status == "for_delivery",
              lock: "FOR UPDATE SKIP LOCKED",
              select: sms.id
          )

        {_count, sms_notifications} =
          Repo.update_all(
            from(sms in SmsNotification,
              where: sms.id in ^for_delivery_ids
            ),
            [set: [status: "queued_for_delivery"]],
            # returns all fields
            returning: true
          )

        sms_notifications
      end)

    results
  end
end
