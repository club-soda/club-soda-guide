defmodule CsGuideWeb.Plugs.Auth do
  import Plug.Conn

  alias CsGuide.Accounts.User
  # alias CsGuide.Resources.Venue

  def init(default), do: default

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    user = user_id && is_binary(user_id) && User.get(user_id)
    assign(conn, :current_user, user)
  end

  def authenticate_site_admin(conn, _opts) do
    authenticate_user_type(conn, :site_admin)
  end

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

  # def authenticate_venue_owner(conn, _opts \\ %{}) do
  #   venue =
  #     if conn.params["id"] do
  #       Venue.get(conn.params["id"])
  #     else
  #       if conn.params["slug"] do
  #         Venue.get_by(slug: conn.params["slug"])
  #       end
  #     end
  #
  #   venue_owner =
  #     if venue do
  #       conn.assigns[:venue_id] == venue.entry_id
  #     else
  #       false
  #     end
  #
  #   cond do
  #     conn.assigns[:admin] || venue_owner ->
  #       conn
  #
  #     true ->
  #       conn
  #       |> Phoenix.Controller.redirect(to: "/")
  #       |> halt()
  #   end
  # end

  defp put_current_user(conn, user_id) do
    conn
    |> assign(:current_user, user_id)
    |> assign(:user_signed_in?, true)
  end
end
