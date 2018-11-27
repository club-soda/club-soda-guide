module SharedTypes exposing (..)


type alias Drink =
    { name : String
    , brand : String
    , brandId : String
    , abv : Float
    , drink_types : List String
    , description : String
    , image : String
    }
