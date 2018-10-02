defmodule CsGuide.ResourcesTest do
  use CsGuide.DataCase

  alias CsGuide.Resources

  describe "venues" do
    alias CsGuide.Resources.Venue

    @valid_attrs %{phone_number: "some phone_number", postcode: "some postcode", venue_name: "some venue_name"}
    @update_attrs %{phone_number: "some updated phone_number", postcode: "some updated postcode", venue_name: "some updated venue_name"}
    @invalid_attrs %{phone_number: nil, postcode: nil, venue_name: nil}

    def venue_fixture(attrs \\ %{}) do
      {:ok, venue} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Resources.create_venue()

      venue
    end

    test "list_venues/0 returns all venues" do
      venue = venue_fixture()
      assert Resources.list_venues() == [venue]
    end

    test "get_venue!/1 returns the venue with given id" do
      venue = venue_fixture()
      assert Resources.get_venue!(venue.id) == venue
    end

    test "create_venue/1 with valid data creates a venue" do
      assert {:ok, %Venue{} = venue} = Resources.create_venue(@valid_attrs)
      assert venue.phone_number == "some phone_number"
      assert venue.postcode == "some postcode"
      assert venue.venue_name == "some venue_name"
    end

    test "create_venue/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_venue(@invalid_attrs)
    end

    test "update_venue/2 with valid data updates the venue" do
      venue = venue_fixture()
      assert {:ok, venue} = Resources.update_venue(venue, @update_attrs)
      assert %Venue{} = venue
      assert venue.phone_number == "some updated phone_number"
      assert venue.postcode == "some updated postcode"
      assert venue.venue_name == "some updated venue_name"
    end

    test "update_venue/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_venue(venue, @invalid_attrs)
      assert venue == Resources.get_venue!(venue.id)
    end

    test "delete_venue/1 deletes the venue" do
      venue = venue_fixture()
      assert {:ok, %Venue{}} = Resources.delete_venue(venue)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_venue!(venue.id) end
    end

    test "change_venue/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Resources.change_venue(venue)
    end
  end
end
