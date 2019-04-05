defmodule CsGuideWeb.PasswordController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User

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
          |> redirect(to: password_path(conn, :new))
        end
    end
  end

  def update(conn, %{"user" => params, "token" => token}) do
    user = User.get_by(password_reset_token: token)
    now = NaiveDateTime.utc_now()
    user_token = user.password_reset_token
    user_token_expiry = user.password_reset_token_expiry
    pw_changeset = User.set_password_changeset(user, params)

    reset_token_params =
      if user.verified do
        %{
          password_reset_token: nil,
          password_reset_token_expiry: nil
        }
      else
        %{
          password_reset_token: nil,
          password_reset_token_expiry: nil,
          verified: now
        }
      end

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
      |> redirect(to: password_path(conn, :new))
    end
  end

  def admin_reset(conn, %{"user_id" => "all_users"}) do
    Enum.each(User.all(), &send_admin_reset_email/1)

    conn
    |> put_flash(:info, "Email sent to all users")
    |> redirect(to: user_path(conn, :index))
  end

  def admin_reset(conn, %{"user_id" => user_id}) do
    user = User.get(user_id)
    send_admin_reset_email(user)

    conn
    |> put_flash(:info, "Email sent to #{user.email}")
    |> redirect(to: user_path(conn, :index))
  end

  defp send_admin_reset_email(user) do
    one_day = 86400 # one day in seconds
    user = User.reset_password_token(user, one_day * 10)
    {subject, msg} = admin_reset_msg(user)

    CsGuide.Email.send_email(user.email, subject, msg)
    |> @mailer.deliver_now()
  end

  defp admin_reset_msg(user) do
    if user.verified do
      {
        "Please reset your password",
        """
        Please click the following link to reset the password on your account.
        #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit.
        This email request was sent by a site administrator.
        """
      }
    else
      {
        "Please verify your account",
        """
        Please click the following link to verify your account.
        #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit.
        """
      }
    end
  end

  defp get_message(user) do
    """
    Please click the following link to reset the password on your account.
    #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit
    """
  end
end