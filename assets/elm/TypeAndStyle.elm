module TypeAndStyle exposing (Filter, SubFilters(..), drinksTypeAndStyle)


type alias Filter =
    ( String, SubFilters )


type SubFilters
    = SubFilters (List Filter)


drinksTypeAndStyle =
    [ beer, cider, softDrink, spiritsAndPremixed, tonicAndMixers, wine ]


beer : Filter
beer =
    ( "Beer"
    , SubFilters
        [ ( "Amber ale", SubFilters [] )
        , ( "Buchabeer", SubFilters [] )
        , ( "Flemish Primitive", SubFilters [] )
        , ( "IPA", SubFilters [] )
        , ( "Fruit Beer", SubFilters [] )
        , ( "Lager", SubFilters [] )
        , ( "Malt drink", SubFilters [] )
        , ( "Mild", SubFilters [] )
        , ( "Pale Ale", SubFilters [] )
        , ( "Pilsner", SubFilters [] )
        , ( "Radler", SubFilters [] )
        , ( "Shandy", SubFilters [] )
        , ( "Sour", SubFilters [] )
        , ( "Spiced Ale", SubFilters [] )
        , ( "Stouts & Porters", SubFilters [] )
        , ( "Wheat Beer", SubFilters [] )
        ]
    )


cider : Filter
cider =
    ( "Cider", SubFilters [ ( "Cider", SubFilters [] ), ( "Fruit Cider", SubFilters [] ), ( "Perry", SubFilters [] ) ] )


softDrink : Filter
softDrink =
    ( "Soft Drink"
    , SubFilters
        [ ( "Cola", SubFilters [] )
        , ( "Cordial", SubFilters [] )
        , ( "Cordial", SubFilters [] )
        , ( "Seasonal", SubFilters [] )
        , ( "Fruit Drinks", SubFilters [] )
        , ( "Ginger Ale", SubFilters [] )
        , ( "Ginger Beer", SubFilters [] )
        , ( "Kombucha", SubFilters [] )
        , ( "Lemonade", SubFilters [] )
        , ( "Mocktails", SubFilters [] )
        , ( "Pre Mixed Drink", SubFilters [] )
        , ( "Rocktails", SubFilters [] )
        , ( "Shandy", SubFilters [] )
        , ( "Shrub", SubFilters [] )
        , ( "Soda", SubFilters [] )
        , ( "Sparkling Pressé", SubFilters [] )
        , ( "Tonic Water", SubFilters [] )
        ]
    )


spiritsAndPremixed : Filter
spiritsAndPremixed =
    ( "Spirits & Premixed"
    , SubFilters
        [ ( "Botanical", SubFilters [] )
        , ( "Cordial", SubFilters [] )
        , ( "Mixer", SubFilters [] )
        , ( "Mocktails", SubFilters [] )
        , ( "Pre Mixed Drink", SubFilters [] )
        , ( "Spirit", SubFilters [] )
        ]
    )


tonicAndMixers : Filter
tonicAndMixers =
    ( "Tonics & Mixers"
    , SubFilters
        [ ( "Mixer", SubFilters [] )
        , ( "Soda", SubFilters [] )
        , ( "Tonic Water", SubFilters [] )
        ]
    )


wine : Filter
wine =
    ( "Wine"
    , SubFilters
        [ ( "Red Wine", SubFilters [] )
        , ( "Rose Wine", SubFilters [] )
        , ( "Sparkling Wine", SubFilters [] )
        , ( "White Wine", SubFilters [] )
        ]
    )
