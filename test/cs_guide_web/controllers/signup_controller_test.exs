defmodule CsGuideWeb.SignupControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Categories.VenueType

  @create_attrs %{
    parent_company: "Parent Co",
    address: "number and road",
    city: "London",
    phone_number: "01234567890",
    postcode: "EC1M 5AD",
    venue_name: "The Example Pub",
    venue_types: %{"Bar" => "on"},
    users: %{"0" => %{"email" => "bob@dwyl.com"}},
    t_and_c: true,
    cookies: true
  }

  describe "List new venue with signup endpoint" do
    setup [:add_type]

    test "create venue", %{conn: conn} do
      conn = post(conn, signup_path(conn, :create), venue: @create_attrs)
      assert %{slug: slug} = redirected_params(conn)
      assert redirected_to(conn) == venue_path(conn, :show, slug)

      conn = get(conn, venue_path(conn, :show, slug))
      assert html_response(conn, 200) =~ "The Example Pub"
    end

    test "create venue with a user who has not agreed to cookies or ts and cs", %{conn: conn} do
      create_attrs = Map.put(@create_attrs, :t_and_c, nil)
      conn = post(conn, signup_path(conn, :create), venue: create_attrs)

      assert html_response(conn, 200) =~ "Create a Venue Listing"
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
