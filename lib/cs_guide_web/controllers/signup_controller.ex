defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Accounts.User, Resources.Venue, Auth}

  def create(conn, %{"venue" => %{"users" => users} = venue} = params) do
    case Venue.insert(venue) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue created successfully.")
        |> Auth.venue_owner(venue)
        |> redirect(to: venue_path(conn, :show, venue.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render(:new,
          user_changeset: changeset,
          venue_changeset: changeset,
          changeset: changeset
        )
    end
  end
end
