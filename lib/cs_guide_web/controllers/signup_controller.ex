defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.{User, VenueUser}
  alias CsGuide.Resources.Venue
  alias CsGuide.{Auth, Mailer, Repo}

  @mailer Application.get_env(:cs_guide, :mailer) || Mailer
  @one_day 86400 # number of seconds in one day
  @five_days @one_day * 5

  # create for users who are not logged in
  def create(conn, %{"venue" => %{"users" => users} = venue_params}) do
    %{"0" => %{"email" => email}} = users
    venue_params = put_in(venue_params, ["users", "0", "role"], "venue_admin")
    changeset = Venue.changeset(%Venue{}, venue_params)

    with(
      true <- changeset.valid?,
      nil <- User.get_by(email_hash: email),
      {:ok, venue} <- Venue.insert(changeset, venue_params)
    ) do
      user =
        venue.users
        |> Enum.at(0)
        |> User.reset_password_token(@five_days)
        |> User.verify_user()

      send_email(user)

      conn
      |> put_flash(:info, "Venue created successfully. Email has been sent to allow you to confirm your account")
      |> Auth.login(user)
      |> redirect(to: venue_path(conn, :show, venue.slug))

    else
      # If email address already belongs to a user
      %User{} ->
        conn
        |> put_flash(:error, "Email address already in use.")
        |> put_view(CsGuideWeb.UserView)
        |> render("new.html", changeset: changeset)

      # if changeset is invalid or insert fails
      _ ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render("new.html", changeset: changeset)
    end
  end

  # create for logged in users
  def create(conn, %{"venue" => venue_params}) do
    changeset = Venue.changeset(%Venue{}, venue_params)
    user = conn.assigns.current_user

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        # associate the user with the venue (add them to venues_users table)
        Repo.insert!(%VenueUser{venue_id: venue.id, user_id: user.id})

        conn
        |> put_flash(:info, "Venue created successfully")
        |> redirect(to: venue_path(conn, :show, venue.slug))

      {:error, changeset} ->
        conn
        |> put_view(CsGuideWeb.UserView)
        |> render("new.html", changeset: changeset)
    end
  end

  defp send_email(user) do
    subject = "Venue Created!"

    CsGuide.Email.send_email(user.email, subject, get_message(user))
    |> @mailer.deliver_now()
  end

  defp get_message(user) do
    """
    Your venue has been set up successfully!
    Now all you need to do is use the link below to verify your account and set up your password.
    #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit
    """
  end
end
