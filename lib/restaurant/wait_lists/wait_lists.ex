defmodule HoldUp.WaitLists do
  @moduledoc """
  The WaitLists context.
  """

  import Ecto.Query, warn: false
  alias HoldUp.Repo

  alias HoldUp.WaitLists.WaitList
  alias HoldUp.WaitLists.StandBy
  alias HoldUp.WaitLists.Messenger

  @doc """
  Gets a single wait_list.

  Raises `Ecto.NoResultsError` if the Wait list does not exist.

  ## Examples

      iex> get_wait_list!(123)
      %WaitList{}

      iex> get_wait_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wait_list!(id) do
    # This method does two queries because of the preload.

    stand_bys_query = from s in StandBy,
                        where: is_nil(s.attended_at) and is_nil(s.no_show_at)

    Repo.one(from w in WaitList, preload: [stand_bys: ^stand_bys_query])
  end

  def get_stand_by!(id) do
    Repo.get!(StandBy, id)
  end

  def add_stand_by(%StandBy{} = stand_by_attrs) do
    %StandBy{}
    |> StandBy.changeset(stand_by_attrs)
    |> Repo.insert
  end

  @doc """
  Creates a stand_by.

  ## Examples

      iex> create_stand_by(%{field: value})
      {:ok, %StandBy{}}

      iex> create_stand_by(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stand_by(wait_list_id, attrs \\ %{}) do
    %StandBy{}
    |> StandBy.changeset(Map.put(attrs, "wait_list_id", wait_list_id))
    |> Repo.insert()
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
  def change_stand_by(%StandBy{} = stand_by) do
    StandBy.changeset(stand_by, %{})
  end

  def party_size_breakdown(stand_bys) do
    grouped = Enum.group_by(stand_bys, fn x -> x.party_size end, fn x -> x.id end)
    Enum.map(grouped, fn {k, v} -> %{ name: k, y: length(v) } end)
  end

  def notify_stand_by(stand_by_id) do
    stand_by = get_stand_by!(stand_by_id)
    body = "hello #{stand_by.name}, your table is ready for you now."
    send_sms_task = Task.start(fn -> Messenger.send_message(stand_by.contact_phone_number, body) end)
    update_stand_by(stand_by, %{notified_at: DateTime.utc_now})
  end

  def mark_as_attended(stand_by_id) do
    stand_by = get_stand_by!(stand_by_id)
    update_stand_by(stand_by, %{attended_at: DateTime.utc_now})
  end

  def mark_as_no_show(stand_by_id) do
    stand_by = get_stand_by!(stand_by_id)
    update_stand_by(stand_by, %{no_show_at: DateTime.utc_now})
  end

  def calculate_average_wait_time(wait_list_id) do
    {:ok, start_of_today} = NaiveDateTime.new(Date.utc_today,  ~T[00:00:00])
    db_result = Repo.one(from s in StandBy,
      where: not is_nil(s.notified_at) and s.wait_list_id == ^wait_list_id and s.inserted_at > ^start_of_today,
      select: avg(s.notified_at - s.inserted_at))

    case db_result do
      %Postgrex.Interval{days: _d, months: _m, secs: seconds} -> round(seconds / 60)
      _ -> 0
    end
  end
end