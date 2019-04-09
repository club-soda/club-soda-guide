defmodule CsGuide.PostcodeLatLongTest do
  use CsGuideWeb.ConnCase
  alias CsGuide.{Categories, Resources}
  alias CsGuide.Resources.Venue
  import Ecto.Query, only: [from: 2]

  @venue [
    %{
      venue_name: "The Not Favourite Pub",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "E2 0SY",
      lat: "51.529675468124100",
      long: "-0.042065456864592",
      slug: "the-favourite-pub-e2-0sy"
    },
    %{
      venue_name: "diff name, same location",
      parent_company: "Parent Co",
      favourite: false,
      venue_types: %{"Pubs" => "on"},
      postcode: "E2 0SY",
      lat: "51.529675468124100",
      long: "-0.042065456864592",
      slug: "the-favourite-pub-e2-0sy"
    }
  ]

  describe "Testing venues_within_distance function" do
    setup [:create_venue]

    test "Only returns most recent version of a venue" do
      lat = 51.54359770000001
      long = -0.08807799999999999

      Venue.get_by(venue_name: "The Not Favourite Pub")
      |> Venue.update(%{city: "London"})

      query = from(v in Venue, where: v.venue_name == "The Not Favourite Pub")

      all_not_fav_count =
        CsGuide.Repo.all(query)
        |> count_no_times_venue_occurs("The Not Favourite Pub")

      all_not_fav_count_from_nearest =
        Venue.nearest_venues(lat, long)
        |> count_no_times_venue_occurs("The Not Favourite Pub")

      assert all_not_fav_count == 2
      assert all_not_fav_count_from_nearest == 1
    end

    test "Venues that are equal distances away from the user both display" do
      lat = 51.54359770000001
      long = -0.08807799999999999

      venues = Venue.nearest_venues(lat, long)
      assert length(venues) == 2
    end

    test "deleted venues do not display" do
      lat = 51.54359770000001
      long = -0.08807799999999999

      Venue.get_by(venue_name: "The Not Favourite Pub")
      |> Venue.delete()

      venues = Venue.nearest_venues(lat, long)
      assert length(venues) == 1
    end
  end

  def count_no_times_venue_occurs(venues, name) do
    Enum.count(venues, &(&1.venue_name == name))
  end

  def fixture(:venue) do
    %Categories.VenueType{}
    |> Categories.VenueType.changeset(%{name: "Pubs"})
    |> Categories.VenueType.insert()

    %Categories.VenueType{}
    |> Categories.VenueType.changeset(%{name: "Retailer"})
    |> Categories.VenueType.insert()

    @venue
    |> Enum.map(fn v ->
      {:ok, venue} = Resources.Venue.insert(v)
      venue
    end)
  end

  def create_venue(_) do
    venue = fixture(:venue)
    {:ok, venue: venue}
  end
end
