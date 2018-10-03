defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Accounts, Accounts.User, Repo, Resources, Resources.Venue}

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
        |> render(:new, user_changeset: changeset, venue_changeset: changeset)
    end
  end
end
