defmodule CsGuideWeb.SignupControllerTest do
  use CsGuideWeb.ConnCase

  alias CsGuide.Categories.VenueType

  @create_attrs %{
    address: "number and road",
    city: "London",
    phone_number: "01234567890",
    postcode: "EC1M 5AD",
    venue_name: "The Example Pub",
    venue_types: %{"Bar" => "on"},
    users:  %{"0" => %{"email" => "bob@dwyl.com"}}
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
  end

  def add_type(_) do
    {:ok, _type} =
      %VenueType{}
      |> VenueType.changeset(%{name: "Bar"})
      |> VenueType.insert()
    :ok
  end
end
