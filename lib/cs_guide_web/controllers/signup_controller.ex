defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Resources.Venue, Auth}

  def create(conn, %{"venue" => %{"users" => users} = venue}) do
    postcode = venue["postcode"]
    slug = Venue.create_slug(venue["venue_name"], postcode)
    venue_params = Map.put(venue, "slug", slug)

    # capturing the email value so that we can email the user a password link
    %{"0" => %{"email" => _email}} = users

    changeset =
      %Venue{}
      |> Venue.changeset(venue_params)
      |> CsGuide.ChangesetHelpers.check_existing_slug(slug, Venue, :venue_name, "Venue already exists")
      |> Venue.validate_postcode(postcode)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        case conn.assigns.current_user do
          nil ->
            # logs the newly created user into the app
            user = venue.users |> Enum.at(0)

            conn
            |> put_flash(:info, "Venue created successfully.")
            |> Auth.login(user)
            |> redirect(to: venue_path(conn, :show, venue.slug))

          _user ->
            # if a user is logged in then we create venue and user but do not log in new user
            conn
            |> put_flash(:info, "Venue created successfully.")
            |> redirect(to: venue_path(conn, :show, venue.slug))
        end

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
