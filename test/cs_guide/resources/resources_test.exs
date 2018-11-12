defmodule CsGuide.ResourcesTest do
  use CsGuide.DataCase

  alias CsGuide.Resources
  alias CsGuide.Resources.Brand
  alias CsGuide.Fixtures

  @create_brand Fixtures.create_brand()

  describe "venues" do
    alias CsGuide.Resources.Venue

    @valid_attrs %{
      venue_name: "some venue_name",
      description: "some description",
      address1: "some address",
      address2: "some address2",
      postcode: "some postcode",
      website: "some website",
      phone_number: "some phone_number",
      facebook: "some facebook",
      instagram: "some instagram"
    }
    @update_attrs %{
      venue_name: "some updated venue_name",
      description: "some updated description",
      address1: "some address",
      address2: "some address2",
      postcode: "some updated postcode",
      website: "some website",
      phone_number: "some updated phone_number",
      facebook: "some facebook",
      instagram: ""
    }
    @invalid_attrs %{
      venue_name: nil,
      description: nil,
      address1: nil,
      address2: nil,
      postcode: nil,
      website: nil,
      phone_number: nil,
      facebook: nil,
      instagram: nil
    }

    def venue_fixture(attrs \\ %{}) do
      {:ok, venue} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Venue.insert()

      venue
    end

    test "all/0 returns all venues" do
      venue = venue_fixture()

      assert Venue.all()
             |> Venue.preload([:drinks, :venue_types]) == [venue]
    end

    test "get/1 returns the venue with given id" do
      venue = venue_fixture()

      assert Venue.get(venue.entry_id)
             |> Venue.preload([:drinks, :venue_types]) == venue
    end

    test "insert/1 with valid data creates a venue" do
      assert {:ok, %Venue{} = venue} = Venue.insert(@valid_attrs)
      assert venue.phone_number == "some phone_number"
      assert venue.postcode == "some postcode"
      assert venue.venue_name == "some venue_name"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Venue.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the venue" do
      venue = venue_fixture()
      assert {:ok, venue} = Venue.update(venue, @update_attrs)
      assert %Venue{} = venue
      assert venue.phone_number == "some updated phone_number"
      assert venue.postcode == "some updated postcode"
      assert venue.venue_name == "some updated venue_name"
    end

    test "update/2 with invalid data returns error changeset" do
      venue = venue_fixture()
      assert {:error, %Ecto.Changeset{}} = Venue.update(venue, @invalid_attrs)
      assert venue == Venue.get(venue.entry_id) |> Venue.preload([:drinks, :venue_types])
    end

    test "changeset/1 returns a venue changeset" do
      venue = venue_fixture()
      assert %Ecto.Changeset{} = Venue.changeset(venue)
    end
  end

  describe "drinks" do
    alias CsGuide.Resources.Drink

    @valid_attrs %{abv: 120.5, name: "some name"}
    @update_attrs %{abv: 456.7, name: "some updated name"}
    @invalid_attrs %{abv: nil, name: nil}

    def drink_fixture(attrs \\ %{}) do
      {:ok, brand} = Brand.insert(@create_brand)

      {:ok, drink} =
        attrs
        |> Map.put(:brand, Map.new([{brand.name, "on"}]))
        |> Enum.into(@valid_attrs)
        |> Drink.insert()

      drink
    end

    test "all/0 returns all drinks" do
      drink = drink_fixture()

      assert Drink.all()
             |> Drink.preload(:drink_types) == [drink]
    end

    test "get/1 returns the drink with given id" do
      drink = drink_fixture()

      assert Drink.get(drink.entry_id)
             |> Drink.preload(:drink_types) == drink
    end

    test "update/2 with valid data updates the drink" do
      drink = drink_fixture()
      assert {:ok, drink} = Drink.update(drink, @update_attrs)
      assert %Drink{} = drink
      assert drink.abv == 456.7
      assert drink.name == "some updated name"
    end

    test "changeset/1 returns a drink changeset" do
      drink = drink_fixture()
      assert %Ecto.Changeset{} = Drink.changeset(drink)
    end
  end

  describe "brands" do
    alias CsGuide.Resources.Brand

    @valid_attrs %{
      description: "some description",
      member: true,
      name: "some name",
      website: "some website",
      logo: "some logo"
    }
    @update_attrs %{
      description: "some updated description",
      member: false,
      name: "some updated name",
      website: "some updated website",
      logo: "some updated logo"
    }
    @invalid_attrs %{description: nil, member: nil, name: nil, website: nil}

    def brand_fixture(attrs \\ %{}) do
      {:ok, brand} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Brand.insert()

      brand
    end

    test "all/0 returns all brands" do
      brand = brand_fixture()
      assert Brand.all() == [brand]
    end

    test "get/1 returns the brand with given id" do
      brand = brand_fixture()
      assert Brand.get(brand.entry_id) == brand
    end

    test "insert/1 with valid data creates a brand" do
      assert {:ok, %Brand{} = brand} = Brand.insert(@valid_attrs)
      assert brand.description == "some description"
      assert brand.member == true
      assert brand.name == "some name"
      assert brand.website == "some website"
      assert brand.logo == "some logo"
    end

    test "insert/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Brand.insert(@invalid_attrs)
    end

    test "update/2 with valid data updates the brand" do
      brand = brand_fixture()
      assert {:ok, brand} = Brand.update(brand, @update_attrs)
      assert %Brand{} = brand
      assert brand.description == "some updated description"
      assert brand.member == false
      assert brand.name == "some updated name"
      assert brand.website == "some updated website"
      assert brand.logo == "some updated logo"
    end

    test "update/2 with invalid data returns error changeset" do
      brand = brand_fixture()
      assert {:error, %Ecto.Changeset{}} = Brand.update(brand, @invalid_attrs)
      assert brand == Brand.get(brand.entry_id)
    end

    test "changeset/1 returns a brand changeset" do
      brand = brand_fixture()
      assert %Ecto.Changeset{} = Brand.changeset(brand, %{})
    end
  end
end
