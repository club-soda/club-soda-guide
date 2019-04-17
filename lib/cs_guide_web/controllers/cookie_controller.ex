defmodule CsGuideWeb.CookieController do
  use CsGuideWeb, :controller

  def accept_cookies(conn, %{"path" => path}) do
    conn
    |> Plug.Conn.put_session(:cookies_accepted, NaiveDateTime.utc_now())
    |> Plug.Conn.configure_session(renew: true)
    |> redirect(to: path)
  end
end