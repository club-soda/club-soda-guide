module DrinksCarousel exposing (..)

import Browser
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)


-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


getDrinks : Cmd Msg
getDrinks =
    Http.get ("/json_drinks") drinksDecoder |> Http.send ReceiveDrinks


drinksDecoder : Decoder (List Drink)
drinksDecoder =
    list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Decode.map3 Drink
        (field "name" string)
        (field "brand" string)
        (field "abv" float)


type alias HttpData data =
    Result Http.Error data


type alias Drink =
    { name : String
    , brand : String
    , abv : Float
    }


type alias Model =
    { drinks : List Drink
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model []
    , getDrinks
    )



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            let
                a =
                    Debug.log "drinks ok" "no"
            in
                ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            let
                a =
                    Debug.log "drinks ok" "yes"
            in
                ( { model | drinks = drinks }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        (List.map
            (\d -> p [] [ text d.name ])
            model.drinks
        )
