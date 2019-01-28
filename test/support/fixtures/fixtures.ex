defmodule CsGuide.Fixtures do
  @moduledoc """
  A module for defining drinks fixtures that can be used in tests.

  This module can be used with a list of fixtures to apply as parameter:

      use CsGuide.Fixtures

      Fixtures.create_drinks()
  """
  @spirits_premixed "Spirits & Premixed"

  def create_venues do
    [
      %{
        venue_name: "Venue A",
        address: "1 number and road",
        city: "London",
        phone_number: "01234567890",
        postcode: "EC1A 7AA",
        drinks: %{"AF Beer 1" => "on"},
        venue_types: %{"Bars" => "on"},
        slug: "venue-a-ec1a-7aa",
        lat: "51.5162121774794",
        long: "-0.101606872279769"
      },
      %{
        venue_name: "Venue B",
        address: "2 number and road",
        city: "London",
        phone_number: "01234567890",
        postcode: "E9 7LH",
        drinks: %{"AF Beer 1" => "on"},
        venue_types: %{"Bars" => "on"},
        slug: "venue-b-e1-7lh",
        lat: "51.5370697966524",
        long: "-0.044906060143753"
      }
    ]
  end

  def create_drinks do
    [
      %{
        entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055a",
        name: "AF Beer 1",
        abv: "0.5",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Beer" => "on"}
      },
      %{
        entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055b",
        name: "AF Beer 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Beer" => "on"}
      },
      %{
        entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055c",
        name: "Low Alc Beer 1",
        abv: "1.5",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Beer" => "on"}
      },
      %{
        entry_id: "0167ce54-95fc-4b28-82a2-147b7b67055d",
        name: "Low Alc Beer 2",
        abv: "1.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Beer" => "on"}
      },
      %{
        entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29a",
        name: "AF Wine 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Wine" => "on"}
      },
      %{
        entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29b",
        name: "AF Wine 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Wine" => "on"}
      },
      %{
        entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29a",
        name: "Low Alc Wine 1",
        abv: "7.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Wine" => "on"}
      },
      %{
        entry_id: "8edf4a7e-d6e7-48b8-abf1-8e1f9aafa29b",
        name: "Low Alc Wine 2",
        abv: "1.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Wine" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee31",
        name: "Soft Drink 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Soft Drink" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee32",
        name: "Soft Drink 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Soft Drink" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee33",
        name: "Soft Drink 3",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Soft Drink" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee21",
        name: "AF Cider 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Cider" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee22",
        name: "AF Cider 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Cider" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee41",
        name: "Tonic 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Tonics & Mixers" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee42",
        name: "Mixer 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Tonics & Mixers" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee43",
        name: "Mixer 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Tonics & Mixers" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee51",
        name: "Spirit 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{@spirits_premixed => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee52",
        name: "Premixed 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{@spirits_premixed => "on"}
      }
    ]
  end

  def create_types do
    [
      %{
        name: "Beer"
      },
      %{
        name: "Wine"
      },
      %{
        name: "Soft Drink"
      },
      %{
        name: "Tonics & Mixers"
      },
      %{
        name: @spirits_premixed
      },
      %{
        name: "Cider"
      }
    ]
  end

  def create_brand do
    %{
      name: "Brewdog",
      description: "Brewdog description",
      deleted: false,
      twitter: "",
      facebook: "",
      instagram: "",
      copy: ""
    }
  end

  def create_venue_types do
    [%{name: "Bars"}, %{name: "Retailer"}, %{name: "Wholesaler"}]
  end
end
