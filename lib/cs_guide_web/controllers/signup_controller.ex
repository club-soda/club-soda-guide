defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Accounts.User, Resources.Venue}

  def create(conn, %{"user" => user, "venue" => venue} = params) do
    case User.insert(user) do
      {:ok, user} ->
        case Venue.insert(venue) do
          {:ok, venue} ->
            conn
            |> put_flash(:info, "Venue created successfully.")
            |> redirect(to: venue_path(conn, :show, venue.entry_id))

          {:error, %Ecto.Changeset{} = changeset} ->
            conn
            |> put_view(CsGuideWeb.UserView)
            |> render(:new, user_changeset: changeset, venue_changeset: changeset)
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render(:new, user_changeset: changeset, venue_changeset: changeset)
    end
  end
end
