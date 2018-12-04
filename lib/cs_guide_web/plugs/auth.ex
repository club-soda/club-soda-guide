defmodule CsGuideWeb.Plugs.Auth do
  import Plug.Conn

  alias CsGuide.Accounts.User

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
      !conn.assigns[:current_user] ->
        conn
        |> Plug.Conn.put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.put_flash(:error, "You must be logged in to access that page")
        |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.session_path(conn, :new))
        |> halt()

      !opts[:admin] || (opts[:admin] && conn.assigns[:admin]) ->
        conn

      true ->
        conn
        |> Phoenix.Controller.redirect(to: "/")
        |> halt()
    end
  end

  defp put_current_user(conn, user_id) do
    conn
    |> assign(:current_user, user_id)
    |> assign(:user_signed_in?, true)
  end
end
