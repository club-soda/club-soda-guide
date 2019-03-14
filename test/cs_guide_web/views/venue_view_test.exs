defmodule CsGuideWeb.VenueViewTest do
  use CsGuideWeb.ConnCase, async: true

  import CsGuideWeb.VenueView

  @drinks [
    %CsGuide.Resources.Drink{
      name: "Drink 1",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 1"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 2",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 2"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 3",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 2"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 4",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 1"
        }
      ]
    }
  ]

  @ordered_drinks [
    %CsGuide.Resources.Drink{
      name: "Drink 1",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 1"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 4",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 1"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 2",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 2"
        }
      ]
    },
    %CsGuide.Resources.Drink{
      name: "Drink 3",
      abv: 0.0,
      drink_types: [
        %CsGuide.Categories.DrinkType{
          name: "Type 2"
        }
      ]
    }
  ]

  test "orders drinks by type" do
    assert order_drinks_by_type(@drinks) == @ordered_drinks
  end
end
