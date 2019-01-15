defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Accounts.User, Resources.Venue, Auth}

  def create(conn, %{"venue" => %{"users" => users} = venue} = params) do
    slug = Venue.create_slug(venue["venue_name"], venue["postcode"])
    venue_params = Map.put(venue, "slug", slug)
    case Venue.insert(venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue created successfully.")
        |> Auth.venue_owner(venue)
        |> redirect(to: venue_path(conn, :show, venue.slug))

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
