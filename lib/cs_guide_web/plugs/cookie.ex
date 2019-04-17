defmodule CsGuideWeb.Plugs.Cookie do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _params) do
    cookies_accepted =
      with(
        cookie when is_nil(cookie) <- get_session(conn, :cookies_accepted),
        user when not is_nil(user) <- conn.assigns.current_user,
        ts when not is_nil(ts) <- user.verified
      ) do
        put_session(conn, :cookies_accepted, ts)
      else
        value -> value
      end

    assign(conn, :cookies_accepted, cookies_accepted)
  end
end