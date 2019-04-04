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
    user = conn.assigns.current_user
    if user && user.role == :site_admin do
      conn
    else
      conn
      |> Phoenix.Controller.put_flash(:error, "You must be logged in to view this page")
      |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.session_path(conn, :new))
      |> halt()
    end
  end

  def authenticate_venue_owner(conn, _opts) do
    user = conn.assigns.current_user
    cond do
      # if user is a site_admin they have full access so just return conn
      user && user.role == :site_admin ->
        conn

      # if venue admin and path is admin/venues/new allow them to proceed
      # all venue admins can do this
      user && user.role == :venue_admin && conn.request_path == "/admin/venues/new" ->
        conn

      # if venue admin and it is a post request to path admin/venues allow them to proceed
      # all venue admins can do this
      user && user.role == :venue_admin && conn.method == "POST" && conn.request_path == "/admin/venues" ->
        conn

      # if user is venue admin
      user && user.role == :venue_admin ->
        case conn.path_params do
          # and path_params contain slug, use the slug to get the venue
          # then check if the venue_owner has access to this venue in question
          %{"slug" => slug} ->
            venue = Venue.get_by(slug: slug)
            if venue && Enum.any?(user.current_users_venues, &(&1 == venue.entry_id)) do
              conn
            else
              conn
              |> Phoenix.Controller.put_flash(:error, "You need to be an this venues admin to access this page")
              |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.page_path(conn, :index))
              |> halt()
            end

          # and path_params contain id, use the id to get the venue
          # then check if the venue_owner has access to this venue in question
          %{"id" => entry_id} ->
            venue = Venue.get(entry_id)
            if venue && Enum.any?(user.current_users_venues, &(&1 == venue.entry_id)) do
              conn
            else
              conn
              |> Phoenix.Controller.put_flash(:error, "You need to be an this venues admin to access this page")
              |> Phoenix.Controller.redirect(to: CsGuideWeb.Router.Helpers.page_path(conn, :index))
              |> halt()
            end
        end

      # if user is not logged in return them to the login screen
      true ->
        conn
        |> Phoenix.Controller.put_flash(:error, "You must be logged in to view this page")
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
