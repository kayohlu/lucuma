defmodule HoldUpWeb.StandByController do
  use HoldUpWeb, :controller

  alias HoldUp.WaitLists
  alias HoldUp.WaitLists.StandBy

  def new(conn, _params) do
    changeset = WaitLists.change_stand_by(%StandBy{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"stand_by" => stand_by_params}) do
    wait_list = WaitLists.get_wait_list!(1)
    case WaitLists.create_stand_by(wait_list.id, stand_by_params) do
      {:ok, stand_by} ->
        conn
        |> put_flash(:info, "Stand by created successfully.")
        |> redirect(to: Routes.wait_list_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    stand_by = WaitLists.get_stand_by!(id)
    render(conn, "show.html", stand_by: stand_by)
  end

  def edit(conn, %{"id" => id}) do
    stand_by = WaitLists.get_stand_by!(id)
    changeset = WaitLists.change_stand_by(stand_by)
    render(conn, "edit.html", stand_by: stand_by, changeset: changeset)
  end

  def update(conn, %{"id" => id, "stand_by" => stand_by_params}) do
    stand_by = WaitLists.get_stand_by!(id)

    case WaitLists.update_stand_by(stand_by, stand_by_params) do
      {:ok, stand_by} ->
        conn
        |> put_flash(:info, "Stand by updated successfully.")
        |> redirect(to: Routes.stand_by_path(conn, :show, stand_by))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", stand_by: stand_by, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    stand_by = WaitLists.get_stand_by!(id)
    {:ok, _stand_by} = WaitLists.delete_stand_by(stand_by)

    conn
    |> put_flash(:info, "Stand by deleted successfully.")
    |> redirect(to: Routes.stand_by_path(conn, :index))
  end
end
