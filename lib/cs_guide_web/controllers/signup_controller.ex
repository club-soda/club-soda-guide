defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.Repo
  alias CsGuide.Accounts
  alias CsGuide.Accounts.User
  alias CsGuide.Resources.Venue
  alias CsGuide.Resources

  def create(conn, %{"user" => user, "venue" => venue} = params) do
    case Accounts.create_user(user) do
      {:ok, user} ->
        case Resources.create_venue(venue) do
          {:ok, venue} ->
            conn
            |> put_flash(:info, "User created successfully.")
            |> put_view(CsGuideWeb.PageView)
            |> render(:index)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render(:new, changeset: changeset)
    end
  end
end
