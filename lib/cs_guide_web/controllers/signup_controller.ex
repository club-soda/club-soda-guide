defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Resources.Venue, Auth}

  def create(conn, %{"venue" => %{"users" => _users} = venue}) do
    postcode = venue["postcode"]
    slug = Venue.create_slug(venue["venue_name"], postcode)
    venue_params = Map.put(venue, "slug", slug)

    changeset =
      %Venue{}
      |> Venue.changeset(venue_params)
      |> Venue.check_existing_slug(slug)
      |> Venue.validate_postcode(postcode)

    case Venue.insert(changeset, venue_params) do
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
