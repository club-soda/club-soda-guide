module TypeAndStyle exposing
    ( Filter
    , FilterId
    , FilterType(..)
    , SubFilters(..)
    , drinksTypeAndStyle
    , getFilterById
    , getFilterId
    , getFilterName
    , getFilterType
    )


type alias Filter =
    ( FilterType, String, SubFilters )


type SubFilters
    = SubFilters (List Filter)


type alias FilterId =
    String


type FilterType
    = Type
    | Style


drinksTypeAndStyle : List Filter
drinksTypeAndStyle =
    [ beer, cider, softDrink, spiritsAndPremixed, tonicAndMixers, wine ]


beer : Filter
beer =
    ( Type
    , "Beer"
    , SubFilters
        [ ( Style, "Amber ale", SubFilters [] )
        , ( Style, "Buchabeer", SubFilters [] )
        , ( Style, "Flemish Primitive", SubFilters [] )
        , ( Style, "IPA", SubFilters [] )
        , ( Style, "Fruit Beer", SubFilters [] )
        , ( Style, "Lager", SubFilters [] )
        , ( Style, "Malt drink", SubFilters [] )
        , ( Style, "Mild", SubFilters [] )
        , ( Style, "Pale Ale", SubFilters [] )
        , ( Style, "Pilsner", SubFilters [] )
        , ( Style, "Radler", SubFilters [] )
        , ( Style, "Shandy", SubFilters [] )
        , ( Style, "Sour", SubFilters [] )
        , ( Style, "Spiced Ale", SubFilters [] )
        , ( Style, "Stouts & Porters", SubFilters [] )
        , ( Style, "Wheat Beer", SubFilters [] )
        ]
    )


cider : Filter
cider =
    ( Type, "Cider", SubFilters [ ( Style, "Cider", SubFilters [] ), ( Style, "Fruit Cider", SubFilters [] ), ( Style, "Perry", SubFilters [] ) ] )


softDrink : Filter
softDrink =
    ( Type
    , "Soft Drink"
    , SubFilters
        [ ( Style, "Cola", SubFilters [] )
        , ( Style, "Cordial", SubFilters [] )
        , ( Style, "Seasonal", SubFilters [] )
        , ( Style, "Fruit Drinks", SubFilters [] )
        , ( Style, "Ginger Ale", SubFilters [] )
        , ( Style, "Ginger Beer", SubFilters [] )
        , ( Style, "Kombucha", SubFilters [] )
        , ( Style, "Lemonade", SubFilters [] )
        , ( Style, "Mocktails", SubFilters [] )
        , ( Style, "Pre Mixed Drink", SubFilters [] )
        , ( Style, "Rocktails", SubFilters [] )
        , ( Style, "Shandy", SubFilters [] )
        , ( Style, "Shrub", SubFilters [] )
        , ( Style, "Soda", SubFilters [] )
        , ( Style, "Sparkling Pressé", SubFilters [] )
        , ( Style, "Tonic Water", SubFilters [] )
        ]
    )


spiritsAndPremixed : Filter
spiritsAndPremixed =
    ( Type
    , "Spirits & Premixed"
    , SubFilters
        [ ( Style, "Botanical", SubFilters [] )
        , ( Style, "Cordial", SubFilters [] )
        , ( Style, "Mixer", SubFilters [] )
        , ( Style, "Mocktails", SubFilters [] )
        , ( Style, "Pre Mixed Drink", SubFilters [] )
        , ( Style, "Spirit", SubFilters [] )
        ]
    )


tonicAndMixers : Filter
tonicAndMixers =
    ( Type
    , "Tonics & Mixers"
    , SubFilters
        [ ( Style, "Mixer", SubFilters [] )
        , ( Style, "Soda", SubFilters [] )
        , ( Style, "Tonic Water", SubFilters [] )
        ]
    )


wine : Filter
wine =
    ( Type
    , "Wine"
    , SubFilters
        [ ( Style, "Red Wine", SubFilters [] )
        , ( Style, "Rose Wine", SubFilters [] )
        , ( Style, "Sparkling Wine", SubFilters [] )
        , ( Style, "White Wine", SubFilters [] )
        ]
    )


getFilterName : Filter -> String
getFilterName ( _, filter, _ ) =
    filter


getFilterId : Filter -> FilterId
getFilterId ( _, filter, _ ) =
    filter


getFilterById : FilterId -> List Filter -> Maybe Filter
getFilterById filterId filters =
    let
        filter =
            List.head filters

        rest =
            List.tail filters
    in
    case filter of
        Nothing ->
            Nothing

        Just ( _, id, SubFilters subFilters ) ->
            if id == filterId then
                filter

            else
                case getFilterById filterId subFilters of
                    Just f ->
                        Just f

                    Nothing ->
                        case rest of
                            Nothing ->
                                Nothing

                            Just r ->
                                getFilterById filterId r


getFilterType : Filter -> FilterType
getFilterType ( typeFilter, _, _ ) =
    typeFilter
