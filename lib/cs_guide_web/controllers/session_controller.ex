defmodule CsGuideWeb.SessionController do
  use CsGuideWeb, :controller
  alias CsGuide.Auth

  def new(conn, _params) do
    render(conn, "new.html", action: session_path(conn, :create))
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Auth.validate_user(email, password) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> (fn c ->
              case user.admin do
                true -> redirect(c, to: "/admin")
                false -> redirect(c, to: "/")
              end
            end).()

      _ ->
        render(conn, "new.html", action: session_path(conn, :create))
    end
  end

  def delete(conn, _params) do
    conn
    |> CsGuide.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end
end
