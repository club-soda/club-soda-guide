defmodule CsGuideWeb.SessionController do
  use CsGuideWeb, :controller

  alias CsGuide.Accounts.User
  alias CsGuide.Auth

  def new(conn, _params) do
    changeset = User.changeset(%User{}, %{})
    render(conn, "new.html", action: session_path(conn, :create))
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case Auth.validate_user(email, password) do
      {:ok, user} -> redirect(conn, to: "/admin")
      _ -> render(conn, "new.html", action: session_path(conn, :create))
    end
  end
end
