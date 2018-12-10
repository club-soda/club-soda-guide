defmodule CsGuide.Fixtures do
  @moduledoc """
  A module for defining drinks fixtures that can be used in tests.

  This module can be used with a list of fixtures to apply as parameter:

      use CsGuide.Fixtures

      Fixtures.create_drinks()
  """
  @spirit "Spirit"
  @premixed "Premixed"

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
        drink_types: %{"Tonic" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee42",
        name: "Mixer 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Mixer" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee43",
        name: "Mixer 2",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{"Mixer" => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee51",
        name: "Spirit 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{@spirit => "on"}
      },
      %{
        entry_id: "587bee17-2034-4466-8396-d5277b1eee52",
        name: "Premixed 1",
        abv: "0.0",
        description: "Description of drink",
        weighting: 1,
        drink_types: %{@premixed => "on"}
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
        name: "Tonic"
      },
      %{
        name: "Mixer"
      },
      %{
        name: @spirit
      },
      %{
        name: @premixed
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
    [%{name: "Bars"}, %{name: "Retailers"}]
  end
end
