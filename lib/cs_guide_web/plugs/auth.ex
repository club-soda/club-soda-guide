defmodule CsGuideWeb.Plugs.Auth do
  import Plug.Conn

  alias CsGuide.Accounts.User
  # alias CsGuide.Resources.Venue

  def init(default), do: default

  def call(conn, _params) do
    user_id = Plug.Conn.get_session(conn, :user_id)

    with true <- is_binary(user_id),
         %User{} = user <- User.get(user_id),
         true <- user.admin do
      conn
      |> put_current_user(user_id)
      |> assign(:admin, true)
    else
      nil ->
        conn
        |> assign(:current_user, nil)
        |> assign(:user_signed_in?, false)

      false ->
        put_current_user(conn, user_id)
    end
  end

  def authenticate_user(conn, opts \\ %{}) do
    cond do
      !opts[:admin] || (opts[:admin] && conn.assigns[:admin]) ->
        conn

      !conn.assigns[:current_user] ->
        conn
        |> Plug.Conn.put_session(:redirect_url, conn.request_path)
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

  def assign_venue_id(conn, _opts \\ %{}) do
    conn
  end

  defp put_current_user(conn, user_id) do
    conn
    |> assign(:current_user, user_id)
    |> assign(:user_signed_in?, true)
  end
end
