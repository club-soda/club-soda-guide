defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Resources.Venue, Auth}

  def create(conn, %{"venue" => %{"users" => users} = venue_params}) do
    postcode = venue_params["postcode"]
    slug = Venue.create_slug(venue_params["venue_name"], postcode)

    venue_params =
      venue_params
      |> Map.put("slug", slug)
      |> put_in(["users", "0", "role"], "venue_admin")

    %{"0" => %{"email" => email}} = users
    subject = "Club Soda account verification"
    message =
      """
      Please click the following link to verify your account and set up a
      password
      """

    changeset =
      %Venue{}
      |> Venue.changeset(venue_params)
      |> CsGuide.ChangesetHelpers.check_existing_slug(slug, Venue, :venue_name, "Venue already exists")
      |> Venue.validate_postcode(postcode)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        CsGuide.Email.send_email(email, subject, message)
        |> CsGuide.Mailer.deliver_now()

        case conn.assigns.current_user do
          nil ->
            # logs the newly created user into the app
            user =
              venue.users
              |> Enum.at(0)
              |> reset_password_token()


            conn
            |> put_flash(:info, "Venue created successfully. Email has been sent for user to confirm account")
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

  defp reset_password_token(user) do
    token = 48 |> :crypto.strong_rand_bytes |> Base.url_encode64
    sent_at = NaiveDateTime.utc_now()
    params = %{password_reset_token: token, password_reset_token_sent_at: sent_at}

    user
    |> Ecto.Changeset.cast(params, [:password_reset_token, :password_reset_token_sent_at])
    |> CsGuide.Repo.update!()
  end
end
