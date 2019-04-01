defmodule CsGuide.SetupHelpers do
  use Phoenix.ConnTest

  import CsGuideWeb.Router.Helpers

  alias CsGuide.Accounts.User

  @endpoint CsGuideWeb.Endpoint

  def admin_login(_) do
    {:ok, _admin} =
      %User{}
      |> User.changeset(%{email: "admin@email", password: "password", role: :site_admin})
      |> User.insert()

    {:ok,
     conn:
       build_conn()
       |> (fn c ->
             post(c, session_path(c, :create, email: "admin@email", password: "password"))
           end).()}
  end

  def venue_admin_login(_) do
    {:ok, _admin} =
      %User{}
      |> User.changeset(%{email: "venueadmin@email", password: "password", role: :venue_admin})
      |> User.insert()

    {:ok,
     conn:
       build_conn()
       |> (fn c ->
             post(c, session_path(c, :create, email: "venueadmin@email", password: "password"))
           end).()}
  end
end
