module SearchAll exposing (main)

import Browser
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
        [ div [ class "w-90 center" ]
            [ p [] [ text "Filters Section" ] ]
        , div [ class "w-90 center" ]
            [ renderSearch model ]
        ]


renderSearch : Model -> Html Msg
renderSearch model =
    div [] []
