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
  Returns an `%Ecto.Changeset{}` for tracking wait_list changes.

  ## Examples

      iex> change_wait_list(wait_list)
      %Ecto.Changeset{source: %WaitList{}}

  """
  def change_wait_list(%WaitList{} = wait_list) do
    WaitList.changeset(wait_list, %{})
  end
end
