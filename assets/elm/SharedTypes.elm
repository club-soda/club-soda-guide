module SharedTypes exposing (..)


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
  { id: String
  , name: String
  , types: List String
  , postcode: String
  , cs_score: Float
  , image: String
  }
