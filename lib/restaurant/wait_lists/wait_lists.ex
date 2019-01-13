defmodule Restaurant.WaitLists do
  @moduledoc """
  The WaitLists context.
  """

  import Ecto.Query, warn: false
  alias Restaurant.Repo

  alias Restaurant.WaitLists.WaitList

  @doc """
  Returns the list of wait_lists.

  ## Examples

      iex> list_wait_lists()
      [%WaitList{}, ...]

  """
  def list_wait_lists do
    Repo.all(WaitList)
  end

  @doc """
  Gets a single wait_list.

  Raises `Ecto.NoResultsError` if the Wait list does not exist.

  ## Examples

      iex> get_wait_list!(123)
      %WaitList{}

      iex> get_wait_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_wait_list!(id), do: Repo.get!(WaitList, id)

  @doc """
  Creates a wait_list.

  ## Examples

      iex> create_wait_list(%{field: value})
      {:ok, %WaitList{}}

      iex> create_wait_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_wait_list(attrs \\ %{}) do
    %WaitList{}
    |> WaitList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a wait_list.

  ## Examples

      iex> update_wait_list(wait_list, %{field: new_value})
      {:ok, %WaitList{}}

      iex> update_wait_list(wait_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_wait_list(%WaitList{} = wait_list, attrs) do
    wait_list
    |> WaitList.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a WaitList.

  ## Examples

      iex> delete_wait_list(wait_list)
      {:ok, %WaitList{}}

      iex> delete_wait_list(wait_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_wait_list(%WaitList{} = wait_list) do
    Repo.delete(wait_list)
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
