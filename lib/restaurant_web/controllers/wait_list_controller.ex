defmodule RestaurantWeb.WaitListController do
  use RestaurantWeb, :controller

  alias Restaurant.WaitLists
  alias Restaurant.WaitLists.WaitList

  def index(conn, _params) do
    wait_lists = WaitLists.list_wait_lists()
    render(conn, "index.html", wait_lists: wait_lists)
  end

  def new(conn, _params) do
    changeset = WaitLists.change_wait_list(%WaitList{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"wait_list" => wait_list_params}) do
    case WaitLists.create_wait_list(wait_list_params) do
      {:ok, wait_list} ->
        conn
        |> put_flash(:info, "Wait list created successfully.")
        |> redirect(to: Routes.wait_list_path(conn, :show, wait_list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    wait_list = WaitLists.get_wait_list!(id)
    render(conn, "show.html", wait_list: wait_list)
  end

  def edit(conn, %{"id" => id}) do
    wait_list = WaitLists.get_wait_list!(id)
    changeset = WaitLists.change_wait_list(wait_list)
    render(conn, "edit.html", wait_list: wait_list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "wait_list" => wait_list_params}) do
    wait_list = WaitLists.get_wait_list!(id)

    case WaitLists.update_wait_list(wait_list, wait_list_params) do
      {:ok, wait_list} ->
        conn
        |> put_flash(:info, "Wait list updated successfully.")
        |> redirect(to: Routes.wait_list_path(conn, :show, wait_list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", wait_list: wait_list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    wait_list = WaitLists.get_wait_list!(id)
    {:ok, _wait_list} = WaitLists.delete_wait_list(wait_list)

    conn
    |> put_flash(:info, "Wait list deleted successfully.")
    |> redirect(to: Routes.wait_list_path(conn, :index))
  end
end
