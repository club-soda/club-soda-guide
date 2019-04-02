defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.{Resources.Venue, Auth}

  @site_url Application.get_env(:cs_guide, :site_url)
  @mailer Application.get_env(:cs_guide, :mailer) || CsGuide.Mailer

  def create(conn, %{"venue" => %{"users" => users} = venue_params}) do
    postcode = venue_params["postcode"]
    slug = Venue.create_slug(venue_params["venue_name"], postcode)

    venue_params =
      venue_params
      |> Map.put("slug", slug)
      |> put_in(["users", "0", "role"], "venue_admin")

    %{"0" => %{"email" => email}} = users
    subject = "Club Soda account verification"

    changeset =
      %Venue{}
      |> Venue.changeset(venue_params)
      |> CsGuide.ChangesetHelpers.check_existing_slug(slug, Venue, :venue_name, "Venue already exists")
      |> Venue.validate_postcode(postcode)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        one_day = 86400 # number of seconds in one day
        five_days = one_day * 5
        
        user =
          venue.users
          |> Enum.at(0)
          |> CsGuide.Accounts.User.reset_password_token(five_days)

        CsGuide.Email.send_email(email, subject, get_message(user))
        |> @mailer.deliver_now()

        case conn.assigns.current_user do
          nil ->
            # logs the newly created user into the app
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

  defp get_message(user) do
    """
    Please click the following link to verify your account and set a password.
    #{@site_url}/password/#{user.password_reset_token}/edit
    """
  end
end
