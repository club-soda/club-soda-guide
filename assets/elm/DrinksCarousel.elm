port module DrinksCarousel exposing (HttpData, Model, Msg(..), drinkDecoder, drinksDecoder, getDrinkByIndex, getDrinks, init, main, renderDrinksCarousel, subscriptions, swipe, update, view)

import Array exposing (..)
import Browser
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import SharedTypes exposing (Drink)



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
    Http.get "/json_drinks" drinksDecoder |> Http.send ReceiveDrinks


drinksDecoder : Decoder (List Drink)
drinksDecoder =
    Decode.list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Decode.map8 Drink
        (field "name" string)
        (field "brand" string)
        (field "brandId" string)
        (field "abv" float)
        (field "drink_types" (Decode.list string))
        (field "drink_styles" (Decode.list string))
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
    | CarouselRight
    | CarouselLeft
    | Swipe String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks }, Cmd.none )

        CarouselLeft ->
            ( { model | carouselIndex = modBy 12 model.carouselIndex + 1 }, Cmd.none )

        CarouselRight ->
            ( { model | carouselIndex = modBy 12 model.carouselIndex - 1 }, Cmd.none )

        Swipe dir ->
            let
                newIndex =
                    case dir of
                        "right" ->
                            modBy 12 model.carouselIndex - 1

                        "left" ->
                            modBy 12 model.carouselIndex + 1

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
        [ img [ src "images/up-chevron.svg", alt "left arrow", class "dn db-ns f1 b pointer absolute-vertical-center left-2 rotate-270 h1", onClick CarouselLeft ] []
        , div [ class "flex-ns flex-wrap justify-center pv4-ns dn dib-ns" ]
            (renderDrinksCarousel model 3)
        , div [ class "flex-wrap justify-center db dn-ns", id "carousel" ]
            (renderDrinksCarousel model 0)
        , img [ src "images/up-chevron.svg", alt "right arrow", onClick CarouselRight, class "dn db-ns f1 b pointer absolute-vertical-center right-2 rotate-90 h1" ] []
        ]


renderDrinksCarousel : Model -> Int -> List (Html Msg)
renderDrinksCarousel model displayXDrinks =
    List.range model.carouselIndex (model.carouselIndex + displayXDrinks)
        |> List.map (\index -> getDrinkByIndex model <| modBy 12 index)
        |> List.indexedMap drinkCard


getDrinkByIndex model index =
    Array.fromList model.drinks
        |> Array.get index
        |> Maybe.withDefault (Drink "" "" "" 0.0 [] [] "" "")
