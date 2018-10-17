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

  describe "drinks" do
    alias CsGuide.Resources.Drink

    @valid_attrs %{abv: 120.5, brand: "some brand", name: "some name"}
    @update_attrs %{abv: 456.7, brand: "some updated brand", name: "some updated name"}
    @invalid_attrs %{abv: nil, brand: nil, name: nil}

    def drink_fixture(attrs \\ %{}) do
      {:ok, drink} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Resources.create_drink()

      drink
    end

    test "list_drinks/0 returns all drinks" do
      drink = drink_fixture()
      assert Resources.list_drinks() == [drink]
    end

    test "get_drink!/1 returns the drink with given id" do
      drink = drink_fixture()
      assert Resources.get_drink!(drink.id) == drink
    end

    test "create_drink/1 with valid data creates a drink" do
      assert {:ok, %Drink{} = drink} = Resources.create_drink(@valid_attrs)
      assert drink.abv == 120.5
      assert drink.brand == "some brand"
      assert drink.name == "some name"
    end

    test "create_drink/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_drink(@invalid_attrs)
    end

    test "update_drink/2 with valid data updates the drink" do
      drink = drink_fixture()
      assert {:ok, drink} = Resources.update_drink(drink, @update_attrs)
      assert %Drink{} = drink
      assert drink.abv == 456.7
      assert drink.brand == "some updated brand"
      assert drink.name == "some updated name"
    end

    test "update_drink/2 with invalid data returns error changeset" do
      drink = drink_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_drink(drink, @invalid_attrs)
      assert drink == Resources.get_drink!(drink.id)
    end

    test "delete_drink/1 deletes the drink" do
      drink = drink_fixture()
      assert {:ok, %Drink{}} = Resources.delete_drink(drink)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_drink!(drink.id) end
    end

    test "change_drink/1 returns a drink changeset" do
      drink = drink_fixture()
      assert %Ecto.Changeset{} = Resources.change_drink(drink)
    end
  end

  describe "brands" do
    alias CsGuide.Resources.Brand

    @valid_attrs %{description: "some description", logo: "some logo", member: true, name: "some name", website: "some website"}
    @update_attrs %{description: "some updated description", logo: "some updated logo", member: false, name: "some updated name", website: "some updated website"}
    @invalid_attrs %{description: nil, logo: nil, member: nil, name: nil, website: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Resources.create_brand()

      brand
    end

    test "list_brands/0 returns all brands" do
      brand = brand_fixture()
      assert Resources.list_brands() == [brand]
    end

    test "get_brand!/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Resources.get_brand!(brand.id) == brand
    end

    test "create_brand/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Resources.create_brand(@valid_attrs)
      assert brand.description == "some description"
      assert brand.logo == "some logo"
      assert brand.member == true
      assert brand.name == "some name"
      assert brand.website == "some website"
    end

    test "create_brand/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Resources.create_brand(@invalid_attrs)
    end

    test "update_brand/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, brand} = Resources.update_brand(brand, @update_attrs)
      assert %Brand{} = brand
      assert brand.description == "some updated description"
      assert brand.logo == "some updated logo"
      assert brand.member == false
      assert brand.name == "some updated name"
      assert brand.website == "some updated website"
    end

    test "update_brand/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Resources.update_brand(brand, @invalid_attrs)
      assert brand == Resources.get_brand!(brand.id)
    end

    test "delete_brand/1 deletes the brand" do
      brand = brand_fixture()
      assert {:ok, %Brand{}} = Resources.delete_brand(brand)
      assert_raise Ecto.NoResultsError, fn -> Resources.get_brand!(brand.id) end
    end

    test "change_brand/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Resources.change_brand(brand)
    end
  end
end
