defmodule CsGuideWeb.SignupControllerTest do
  use CsGuideWeb.ConnCase

  import CsGuide.SetupHelpers
  import Ecto.Query

  alias CsGuide.Repo
  alias CsGuide.Categories.VenueType
  alias CsGuide.Accounts.{User, VenueUser}
  alias CsGuide.Resources.Venue

  @create_attrs %{
    parent_company: "Parent Co",
    address: "number and road",
    city: "London",
    phone_number: "01234567890",
    postcode: "EC1M 5AD",
    venue_name: "The Example Pub",
    venue_types: %{"Bar" => "on"},
    users: %{"0" => %{"email" => "bob@dwyl.com"}}
  }

  describe "List new venue with signup endpoint when no user logged in" do
    setup [:add_type]

    test "create venue", %{conn: conn} do
      conn = post(conn, signup_path(conn, :create), venue: @create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, slug)

      conn = get(conn, venue_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "The Example Pub"
    end

    test "create venue with an email address that is already in use fails", %{conn: conn} do
      %User{} |> User.changeset(%{email: "bob@dwyl.com"}) |> User.insert()

      conn = post(conn, signup_path(conn, :create), venue: @create_attrs)
      assert html_response(conn, 200) =~ "Email address already in use"
    end
  end

  describe "List new venue with signup endpoint when user is logged in" do
    setup [:add_type, :venue_admin_login]

    test "create venue", %{conn: conn} do
      venue_admin = User.get_by(email_hash: "venueadmin@email")

      # removes users as logged in users do not have that option in the form
      create_attrs = Map.delete(@create_attrs, :users)
      conn = post(conn, signup_path(conn, :create), venue: create_attrs)

      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, slug)

      conn = get(conn, venue_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "The Example Pub"

      venue = Venue.get_by(venue_name: "The Example Pub")
      query = from vu in VenueUser, where: vu.user_id == ^venue_admin.id
      venue_user = Repo.one(query)

      refute venue_user == nil
      assert venue_user.venue_id == venue.id
    end
  end

  def add_type(_) do
    {:ok, _type} =
      %VenueType{}
      |> VenueType.changeset(%{name: "Bar"})
      |> VenueType.insert()

    :ok
  end
end
