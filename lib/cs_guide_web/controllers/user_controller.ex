defmodule CsGuideWeb.UserController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User
  alias CsGuide.Resources.Venue

  def index(conn, _params) do
    users = User.all()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    user_changeset = User.changeset(%User{}, %{})
    venue_changeset = Venue.changeset(%Venue{users: [user_changeset]}, %{})

    render(conn, "new.html", changeset: venue_changeset)
  end

  # Doesn't look like this route is ever used. There is a test for it but that
  # all I can find.
  # The new action above takes a user to a form that has a post request that
  # takes users to # /signup create
  def create(conn, %{"user" => user_params}) do
    case %User{} |> User.changeset(user_params) |> User.insert() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = User.get(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = User.get(id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = User.get(id)

    case user |> User.changeset(user_params) |> User.update() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  # def delete(conn, %{"id" => id}) do
  # user = Accounts.get_user!(id)
  # {:ok, _user} = Accounts.delete_user(user)

  # conn
  # |> put_flash(:info, "User deleted successfully.")
  # |> redirect(to: user_path(conn, :index))
  # end
end
