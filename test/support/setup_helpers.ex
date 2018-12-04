defmodule CsGuide.SetupHelpers do
  use Phoenix.ConnTest

  import CsGuideWeb.Router.Helpers

  alias CsGuide.Accounts.User

  @endpoint CsGuideWeb.Endpoint

  def admin_login(_) do
    {:ok, admin} = User.insert(%{email: "admin@email", password: "password", admin: true})

    {:ok,
     conn:
       build_conn()
       |> (fn c ->
             post(c, session_path(c, :create, email: "admin@email", password: "password"))
           end).()}
  end
end
