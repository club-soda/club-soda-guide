defmodule CsGuideWeb.SignupController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User
  alias CsGuide.Resources.Venue
  alias CsGuide.{Auth, Mailer}

  @mailer Application.get_env(:cs_guide, :mailer) || Mailer
  @one_day 86400 # number of seconds in one day
  @five_days @one_day * 5

  def create(conn, %{"venue" => venue_params}) do
    venue_params = put_in(venue_params, ["users", "0", "role"], "venue_admin")
    changeset = Venue.changeset(%Venue{}, venue_params)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        user =
          venue.users
          |> Enum.at(0)
          |> User.reset_password_token(@five_days)

        send_email(user)

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
