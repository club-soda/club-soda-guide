defmodule CsGuideWeb.PasswordController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User

  @site_url Application.get_env(:cs_guide, :site_url)
  @mailer Application.get_env(:cs_guide, :mailer) || CsGuide.Mailer

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    user = User.get_by(email_hash: email)

    case user do
      nil ->
        conn
        |> put_flash(:error, "Could not send reset email. Please try again later")
        |> redirect(to: password_path(conn, :new))

      _user ->
        one_day = 86400 # one day in seconds
        user = User.reset_password_token(user, one_day)
        subject = "Reset password email"

        CsGuide.Email.send_email(email, subject, get_message(user))
        |> @mailer.deliver_now()

        conn
        |> put_flash(:info, "If your email address exists in our database, you will receive a password reset link at your email address in a few minutes.")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def edit(conn, %{"token" => token}) do
    # one_day = 86400 # number of seconds in one day
    user = User.get_by(password_reset_token: token)

    case user do
      nil ->
        conn
        |> put_flash(:error, "Invalid password reset token")
        |> redirect(to: password_path(conn, :new))

      _user ->
        now = NaiveDateTime.utc_now()
        user_token = user.password_reset_token
        user_token_expiry = user.password_reset_token_expiry

        # if user has a token and their the time now is before the users
        # token then we allow them to reset a password
        if user_token && NaiveDateTime.compare(now, user_token_expiry) == :lt do
          changeset = User.changeset(%User{}, %{})
          render(conn, "edit.html", changeset: changeset, token: user_token)

        # else the user is taken to the new path
        else
          conn
          |> put_flash(:error, "Password reset token has expired")
          |> redirect(password_path(conn, :new))
        end
    end
  end

  def update(conn, %{"user" => %{"token" => token} = params}) do
    user = User.get_by(password_reset_token: token)
    now = NaiveDateTime.utc_now()
    user_token = user.password_reset_token
    user_token_expiry = user.password_reset_token_expiry
    params = Map.put(params, "verified", now)

    pw_changeset = User.set_password_changeset(user, params)

    reset_token_params = %{
      password_reset_token: nil,
      password_reset_token_expiry: nil,
    }

    if user_token && NaiveDateTime.compare(now, user_token_expiry) == :lt do
      # if token is valid
      with {:ok, user} <- CsGuide.Repo.update(pw_changeset),
           token_reset_changeset <- User.changeset(user, reset_token_params),
           {:ok, user} <- CsGuide.Repo.update(token_reset_changeset) do
           # if a user is logged in. Don't see this happening much in prod but
           # best to be on the safe side
            if conn.assigns.current_user do
              conn
              |> put_flash(:info, "Password updated")
              |> redirect(to: page_path(conn, :index))
            # logs in a user after they have updated their password
            else
              conn
              |> put_flash(:info, "Password updated")
              |> CsGuide.Auth.login(user)
              |> redirect(to: page_path(conn, :index))
            end
      else
      # if either of the changeset functions updating a users password or
      # password_token fields fail we come to this route. Should never happen
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset, token: user_token)
      end
    else
      # if token is expired
      conn
      |> put_flash(:error, "Password reset token has expired")
      |> redirect(password_path(conn, :new))
    end
  end

  defp get_message(user) do
    """
    Please click the following link to reset the password on your account.
    #{@site_url}/password/#{user.password_reset_token}/edit
    """
  end
end