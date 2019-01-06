alias CsGuide.Categories.{DrinkStyle, DrinkType}

beer =
    %{typeName: "Beer",
      styles:
        [  "Amber ale",
         "Buchabeer",
         "Flemish Primitive",
         "IPA",
         "Fruit Beer",
         "Lager",
         "Malt drink",
         "Mild",
         "Pale Ale",
         "Pilsner",
         "Radler",
         "Shandy",
         "Sour",
         "Spiced Ale",
         "Stouts & Porters",
         "Wheat Beer"
        ]
    }

cider =
    %{ typeName: "Cider",
       styles:
          [ "Cider",
            "Fruit Cider",
            "Perry"
          ]
      }

softDrink =
    %{ typeName: "Soft Drink",
       styles:
        [ "Cola",
          "Cordial",
          "Seasonal",
          "Fruit Drinks",
          "Ginger Ale",
          "Ginger Beer",
          "Kombucha",
          "Lemonade",
          "Mocktails",
          "Pre Mixed Drink",
          "Rocktails",
          "Shandy",
          "Shrub",
          "Soda",
          "Sparkling Pressé",
          "Tonic Water"
        ]
    }

spiritsAndPremixed =
    %{ typeName: "Spirits & Premixed",
       styles:
        [ "Botanical",
          "Cordial",
          "Mixer",
          "Mocktails",
          "Pre Mixed Drink",
          "Spirit"
        ]
    }

tonicAndMixers =
    %{ typeName: "Tonics & Mixers",
       styles:
        [ "Mixer",
          "Soda",
          "Tonic Water"
        ]
    }

wine =
    %{ typeName: "Wine",
       styles:
        [ "Red Wine",
          "Rose Wine",
          "Sparkling Wine",
          "White Wine"
        ]
    }


data = [beer, cider, softDrink, spiritsAndPremixed, tonicAndMixers, wine]

Enum.each(data, fn d ->
  type = DrinkType.get_by(name: d.typeName)
  Enum.each(d.styles, fn styleName ->
    style = DrinkStyle.get_by(name: styleName) |> DrinkStyle.preload([:drink_types])
    if style do
      current_types =
        Enum.reduce(style.drink_types, %{}, fn dt, m ->
          Map.put(m, dt.name, "on")
        end)

        param = %{"drink_types" => Map.put(current_types, type.name, "on" )}
        DrinkStyle.update(style, param)
    end
  end)
end)
