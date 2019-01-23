defmodule Restaurant.WaitLists do
  @moduledoc """
  The WaitLists context.
  """

  import Ecto.Query, warn: false
  alias Restaurant.Repo

  alias Restaurant.WaitLists.WaitList
  alias Restaurant.WaitLists.StandBy

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
    Repo.get!(WaitList, id) |> Repo.preload(:stand_bys)
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
end