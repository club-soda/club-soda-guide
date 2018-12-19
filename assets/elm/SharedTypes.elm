module SharedTypes exposing (Drink, Venue, searchDrinkByTerm, searchVenueByTerm)


type alias Drink =
    { name : String
    , brand : String
    , brandId : String
    , abv : Float
    , drink_types : List String
    , drink_styles : List String
    , description : String
    , image : String
    }


type alias Venue =
    { id : String
    , name : String
    , types : List String
    , postcode : String
    , cs_score : Float
    , image : String
    }


searchDrinkByTerm : Maybe String -> Drink -> Bool
searchDrinkByTerm searchTerm drink =
    case searchTerm of
        Nothing ->
            True

        Just term ->
            String.contains (String.toLower term) (String.toLower drink.name)
                || String.contains (String.toLower term) (String.toLower drink.description)
                || String.contains (String.toLower term) (String.toLower drink.brand)


searchVenueByTerm : Maybe String -> Venue -> Bool
searchVenueByTerm searchTerm venue =
    case searchTerm of
        Nothing ->
            True

        Just term ->
            String.contains (String.toLower term) (String.toLower venue.name)
