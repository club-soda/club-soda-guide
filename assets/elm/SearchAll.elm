module SearchAll exposing (main)

import Array exposing (..)
import Browser
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (..)
import Search exposing (..)
import SharedTypes


main =
    Browser.element
        { init = init
        , subscriptions = \_ -> Sub.none
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { drinks : List SharedTypes.Drink
    , venues : List SharedTypes.Venue
    }


type alias Flags =
    { drinks : List SharedTypes.Drink, venues : List SharedTypes.Venue }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.drinks flags.venues, Cmd.none )



-- Msg & UPDATE


type Msg
    = None


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ div [ class "relative w-90 center" ]
            [ p [] [ text "Filters Section" ] ]
        , div [ class "relative w-90 center" ]
            [ h1 [] [ text "Drinks" ]
            , renderDrinks model.drinks
            , h1 [] [ text "Venues" ]
            , renderVenues model.venues
            ]
        ]


renderDrinks : List SharedTypes.Drink -> Html Msg
renderDrinks drinks =
    div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
        (Array.fromList drinks
            |> Array.indexedMap drinkCard
            |> toList
        )


renderVenues : List SharedTypes.Venue -> Html Msg
renderVenues venues =
    div [] (Search.renderVenues venues)
