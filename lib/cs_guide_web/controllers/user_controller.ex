defmodule CsGuideWeb.UserController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User
  alias CsGuide.Resources.Venue

  @mailer Application.get_env(:cs_guide, :mailer) || CsGuide.Mailer

  def index(conn, _params) do
    users = User.all()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    user_changeset = User.changeset(%User{}, %{})
    venue_changeset = Venue.changeset(%Venue{users: [user_changeset]}, %{})

    render(conn, "new.html", changeset: venue_changeset)
  end

  # Doesn't look like this route is ever used. There is a test for it but that
  # all I can find.
  # The new action above takes a user to a form that has a post request that
  # takes users to # /signup create
  def create(conn, %{"user" => user_params}) do
    case %User{} |> User.changeset(user_params) |> User.insert() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = User.get(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = User.get(id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = User.get(id)

    case user |> User.changeset(user_params) |> User.update() do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def new_site_admin(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new_site_admin.html", changeset: changeset)
  end

  def create_site_admin(conn, %{"user" => params}) do
    params = Map.put(params, "role", "site_admin")
    changeset = %User{} |> User.changeset(params)

    case User.insert(changeset) do
      {:ok, user} ->
        subject = "Club Soda site admin"
        one_day = 86400 # one day in seconds
        user = User.reset_password_token(user, one_day * 10)

        CsGuide.Email.send_email(user.email, subject, get_message(user))
        |> @mailer.deliver_now()

        conn
        |> put_flash(:info, "Site admin created successfully. User will receive an email with instructions on setting a password")
        |> redirect(to: admin_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset =
          case changeset.errors do
            [email_hash: {error, _}] ->
              Ecto.Changeset.add_error(changeset, :email, error)
            _ ->
              changeset
          end

        render(conn, "new_site_admin.html", changeset: changeset)
    end
  end

  defp get_message(user) do
    """
    You have been made a site admin.
    Please click the following link to set the password on your account.
    #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit
    """
  end
end
