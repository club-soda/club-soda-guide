defmodule CsGuideWeb.Plugs.Auth do
  import Plug.Conn

  alias CsGuide.Accounts.User

  def init(default), do: default

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    user = user_id && is_binary(user_id) && User.get(user_id)
    assign(conn, :current_user, user)
  end

  def authenticate_site_admin(conn, _opts) do
    authenticate_user_type(conn, :site_admin)
  end

  def authenticate_venue_owner(conn, _opts) do
    authenticate_user_type(conn, :venue_admin)
  end

  defp authenticate_user_type(conn, user_type) do
    user = conn.assigns.current_user
    cond do
      user && user.role == user_type ->
        conn

      user == nil ->
        conn
        # Not sure what this line is for. I think that it can be removed
        # |> Plug.Conn.put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.put_flash(:error, "You must be logged in to access that page")
        |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.session_path(conn, :new))
        |> halt()

      true ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
    end
  end
end
