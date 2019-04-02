defmodule CsGuideWeb.Plugs.Auth do
  import Plug.Conn
  import Ecto.Query, only: [from: 2]

  alias CsGuide.Accounts.User
  alias CsGuide.Resources.Venue

  def init(default), do: default

  def call(conn, _params) do
    user_id = get_session(conn, :user_id)
    user = user_id && is_binary(user_id) && User.get(user_id)
    user = user_id && add_editable_venues(user)
    assign(conn, :current_user, user)
  end

  def authenticate_site_admin(conn, _opts) do
    authenticate_user_type(conn, [:site_admin])
  end

  def authenticate_venue_owner(conn, _opts) do
    authenticate_user_type(conn, [:site_admin, :venue_admin])
  end

  defp authenticate_user_type(conn, user_types) do
    user = conn.assigns.current_user
    if user && Enum.any?(user_types, &(&1 == user.role)) do
      conn
    else
      conn
      |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  defp add_editable_venues(user) do
    if user.role == :venue_admin do
      query =
        from(v in Venue,
        join: vu in "venues_users",
        on: v.id == vu.venue_id,
        where: vu.user_id == ^user.id,
        select: v.entry_id)

      current_users_venues = CsGuide.Repo.all(query)
      Map.put(user, :current_users_venues, current_users_venues)
    else
      user
    end
  end
end
