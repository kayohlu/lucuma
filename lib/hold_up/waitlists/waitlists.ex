defmodule HoldUp.Waitlists do
  @moduledoc """
  The Waitlists context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.Waitlists.Waitlist
  alias HoldUp.Waitlists.StandBy
  alias HoldUp.Notifications
  alias HoldUp.Waitlists.ConfirmationSmsSetting
  alias HoldUp.Waitlists.AttendanceSmsSetting
  alias HoldUpWeb.Router.Helpers

  def get_business_waitlist(business_id) do
    Repo.one(from w in Waitlist, where: w.business_id == ^business_id)
  end

  def get_waitlist!(id) do
    # This method does two queries because of the preload.

    stand_bys_query =
      from s in StandBy,
        where:
          is_nil(s.attended_at) and is_nil(s.no_show_at) and is_nil(s.cancelled_at) and
            s.waitlist_id == ^id

    Repo.one(from w in Waitlist, where: w.id == ^id, preload: [stand_bys: ^stand_bys_query])
  end

  def get_waitlist_stand_bys(waitlist_id) do
    # This method does two queries because of the preload.

    stand_bys_query =
      from s in StandBy,
        where:
          is_nil(s.attended_at) and
            is_nil(s.no_show_at) and
            is_nil(s.cancelled_at) and
            s.waitlist_id == ^waitlist_id,
        order_by: [desc: s.inserted_at]

    Repo.all(stand_bys_query)
  end

  def create_waitlist(attrs \\ %{}) do
    changeset = Waitlist.changeset(%Waitlist{}, attrs)

    if changeset.valid? do
      {:ok, waitlist} = Repo.insert(changeset)

      Repo.transaction(fn ->
        {:ok, confirmation_sms_setting} = create_confirmation_sms_settings(waitlist)
        {:ok, attendance_sms_setting} = create_attendance_sms_settings(waitlist)
        waitlist
      end)
    else
      {:error, %{changeset | action: :waitlist}}
    end
  end

  def create_confirmation_sms_setting(attrs \\ %{}) do
    %ConfirmationSmsSetting{}
    |> ConfirmationSmsSetting.changeset(attrs)
    |> Repo.insert()
  end

  def change_confirmation_sms_setting(%ConfirmationSmsSetting{} = sms_setting) do
    ConfirmationSmsSetting.changeset(sms_setting, %{})
  end

  def create_attendance_sms_setting(attrs \\ %{}) do
    %AttendanceSmsSetting{}
    |> AttendanceSmsSetting.changeset(attrs)
    |> Repo.insert()
  end

  def change_attendance_sms_setting(%AttendanceSmsSetting{} = sms_setting) do
    AttendanceSmsSetting.changeset(sms_setting, %{})
  end

  def new_confirmation_sms_setting_changeset(%ConfirmationSmsSetting{} = confirmation_sms_setting) do
    ConfirmationSmsSetting.changeset(confirmation_sms_setting, %{
        enabled: true,
        message_content: """
        Hello [[NAME]],

        It's your turn!

        Regards,
        Your friendly staff

        To cancel click the link below:
        [[CANCEL_LINK]]
        """
      })
  end

  def new_attendance_sms_setting_changeset(%AttendanceSmsSetting{} = attendance_sms_setting) do
    AttendanceSmsSetting.changeset(attendance_sms_setting, %{
        enabled: true,
        message_content: """
        Hello [[NAME]],

        You've been added to our waitlist. We'll let you know when it's your turn as soon as possible.

        Regards,
        Your friendly staff

        To cancel click the link below:
        [[CANCEL_LINK]]
        """
      })
  end

  defp create_confirmation_sms_settings(waitlist) do
    {:ok, confirmation_sms_setting} =
      create_confirmation_sms_setting(%{
        enabled: true,
        waitlist_id: waitlist.id,
        message_content: """
        Hello [[NAME]],

        It's your turn!

        Regards,
        Your friendly staff

        To cancel click the link below:
        [[CANCEL_LINK]]
        """
      })
  end

  defp create_attendance_sms_settings(waitlist) do
    {:ok, attendance_sms_setting} =
      create_attendance_sms_setting(%{
        enabled: true,
        waitlist_id: waitlist.id,
        message_content: """
        Hello [[NAME]],

        You've been added to our waitlist. We'll let you know when it's your turn as soon as possible.

        Regards,
        Your friendly staff

        To cancel click the link below:
        [[CANCEL_LINK]]
        """
      })
  end

  def update_confirmation_sms_setting(%ConfirmationSmsSetting{} = sms_setting, attrs) do
    sms_setting
    |> ConfirmationSmsSetting.changeset(attrs)
    |> Repo.update()
  end

  def update_attendance_sms_setting(%AttendanceSmsSetting{} = sms_setting, attrs) do
    sms_setting
    |> AttendanceSmsSetting.changeset(attrs)
    |> Repo.update()
  end

  def attendance_sms_setting_for_waitlist(waitlist_id) do
    Repo.one!(from ass in AttendanceSmsSetting, where: ass.waitlist_id == ^waitlist_id)
  end

  def get_stand_by!(id) do
    Repo.get!(StandBy, id)
  end

  @doc """
  Creates a stand_by.

  ## Examples

      iex> create_stand_by(%{field: value})
      {:ok, %StandBy{}}

      iex> create_stand_by(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stand_by(attrs \\ %{}, notification_module \\ Notifications) do
    case %StandBy{} |> StandBy.changeset(attrs) |> Repo.insert() do
      {:ok, stand_by} ->
        confirmation_sms_setting =
          Repo.get_by!(ConfirmationSmsSetting, waitlist_id: stand_by.waitlist_id)

        if confirmation_sms_setting.enabled do
          body =
            confirmation_sms_setting.message_content
            |> String.replace("[[NAME]]", stand_by.name)
            |> String.replace(
              "[[CANCEL_LINK]]",
              Helpers.stand_bys_cancellation_url(
                HoldUpWeb.Endpoint,
                :show,
                stand_by.cancellation_uuid
              )
            )

          notification_module.send_sms_notification(
            stand_by.contact_phone_number,
            body,
            stand_by.id
          )
        end

        {:ok, stand_by}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a stand_by.

  ## Examples

      iex> update_stand_by(stand_by, %{field: new_value})
      {:ok, %StandBy{}}

      iex> update_stand_by(stand_by, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stand_by(%StandBy{} = stand_by, attrs) do
    stand_by
    |> StandBy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a StandBy.

  ## Examples

      iex> delete_stand_by(stand_by)
      {:ok, %StandBy{}}

      iex> delete_stand_by(stand_by)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stand_by(%StandBy{} = stand_by) do
    Repo.delete(stand_by)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stand_by changes.

  ## Examples

      iex> change_stand_by(stand_by)
      %Ecto.Changeset{source: %StandBy{}}

  """
  def change_stand_by(%StandBy{} = stand_by, attrs \\ %{}) do
    StandBy.changeset(stand_by, attrs)
  end

  def party_size_breakdown(waitlist_id) do
    get_waitlist_stand_bys(waitlist_id)
    |> Enum.group_by(fn x -> x.party_size end, fn x -> x.id end)
    |> Enum.map(fn {k, v} -> %{name: k, y: length(v)} end)
  end

  def notify_stand_by(stand_by_id, notification_module \\ Notifications) do
    stand_by = get_stand_by!(stand_by_id)
    attendance_sms_setting = attendance_sms_setting_for_waitlist(stand_by.waitlist_id)

    if attendance_sms_setting.enabled do
      stand_by = get_stand_by!(stand_by_id)

      body =
        attendance_sms_setting.message_content
        |> String.replace("[[NAME]]", stand_by.name)
        |> String.replace(
          "[[CANCEL_LINK]]",
          Helpers.stand_bys_cancellation_url(
            HoldUpWeb.Endpoint,
            :show,
            stand_by.cancellation_uuid
          )
        )

      notification_module.send_sms_notification(stand_by.contact_phone_number, body, stand_by.id)

      update_stand_by(stand_by, %{notified_at: DateTime.utc_now()})
    end
  end

  def mark_as_attended(stand_by_id) do
    stand_by = get_stand_by!(stand_by_id)
    update_stand_by(stand_by, %{attended_at: DateTime.utc_now()})
  end

  def mark_as_no_show(stand_by_id) do
    stand_by = get_stand_by!(stand_by_id)
    update_stand_by(stand_by, %{no_show_at: DateTime.utc_now()})
  end

  def mark_as_cancelled(cancellation_uuid) do
    stand_by = Repo.get_by!(StandBy, cancellation_uuid: cancellation_uuid)
    update_stand_by(stand_by, %{cancelled_at: DateTime.utc_now()})
  end

  def calculate_average_wait_time(waitlist_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today(), ~T[00:00:00])

    IO.inspect(waitlist_id)
    IO.inspect(start_of_today)

    db_result =
      Repo.one(
        from s in StandBy,
          where:
            not is_nil(s.notified_at) and s.waitlist_id == ^waitlist_id and
              s.inserted_at > ^start_of_today,
          select: avg(s.notified_at - s.inserted_at)
      )

    IO.inspect(db_result)

    case db_result do
      %Postgrex.Interval{days: _d, months: _m, secs: seconds} -> round(seconds / 60)
      _ -> 0
    end
  end
end
