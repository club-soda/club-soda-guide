port module DrinksCarousel exposing (..)

import Browser
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Array exposing (..)
import SharedTypes exposing (Drink)
import DrinkCard exposing (drinkCard)


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
    Decode.list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Decode.map7 Drink
        (field "name" string)
        (field "brand" string)
        (field "brandId" string)
        (field "abv" float)
        (field "drink_types" (Decode.list string))
        (field "description" string)
        (field "image" string)


type alias HttpData data =
    Result Http.Error data


type alias Model =
    { drinks : List Drink
    , carouselIndex : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { drinks = []
      , carouselIndex = 0
      }
    , getDrinks
    )



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))
    | IncrementIndexes
    | DecrementIndexes
    | Swipe String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks }, Cmd.none )

        IncrementIndexes ->
            let
                newIndex =
                    if model.carouselIndex <= 1 then
                        model.carouselIndex + 1
                    else
                        0
            in
                ( { model | carouselIndex = newIndex }, Cmd.none )

        DecrementIndexes ->
            let
                newIndex =
                    if model.carouselIndex >= 1 then
                        model.carouselIndex - 1
                    else
                        11
            in
                ( { model | carouselIndex = newIndex }, Cmd.none )

        Swipe dir ->
            let
                newIndex =
                    case dir of
                        "right" ->
                            if model.carouselIndex >= 1 then
                                model.carouselIndex - 1
                            else
                                11

                        "left" ->
                            if model.carouselIndex <= 1 then
                                model.carouselIndex + 1
                            else
                                0

                        _ ->
                            model.carouselIndex
            in
                ( { model | carouselIndex = newIndex }, Cmd.none )


port swipe : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    swipe Swipe



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "relative" ]
        [ p [ class "f1 b pointer absolute-vertical-center left-2", onClick DecrementIndexes ] [ text "<" ]
        , div [ class "flex-ns flex-wrap justify-center pv4-ns db dib-ns", id "carousel" ]
            (renderDrinksCarousel model)
        , p [ class "f1 b pointer absolute-vertical-center right-2", onClick IncrementIndexes ] [ text ">" ]
        ]


renderDrinksCarousel model =
    Array.fromList model.drinks
        |> Array.slice model.carouselIndex (model.carouselIndex + 4)
        |> Array.indexedMap drinkCard
        |> toList
