module SearchDrink exposing (..)

import Browser
import Http
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Array exposing (..)
import SharedTypes exposing (Drink)
import DrinkCard exposing (drinkCard)
import Search exposing (..)


-- MODEL


type alias Model =
    { drinks : List Drink
    , dtype_filter : String
    , abv_filter : String
    , search_term : String
    }


type alias Flags =
    { dtype_filter : String
    }


type alias HttpData data =
    Result Http.Error data


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        dtype_filter =
            if flags.dtype_filter == "default" then
                ""
            else
                flags.dtype_filter
    in
        ( { drinks = []
          , dtype_filter = dtype_filter
          , abv_filter = ""
          , search_term = ""
          }
        , getDrinks
        )


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string


getDrinks : Cmd Msg
getDrinks =
    Http.get ("/json_drinks") drinksDecoder |> Http.send ReceiveDrinks


drinksDecoder : Decoder (List Drink)
drinksDecoder =
    Json.list drinkDecoder


drinkDecoder : Decoder Drink
drinkDecoder =
    Json.map8 Drink
        (field "name" string)
        (field "brand" string)
        (field "brandId" string)
        (field "abv" float)
        (field "drink_types" (Json.list string))
        (field "drink_styles" (Json.list string))
        (field "description" string)
        (field "image" string)



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))
    | SelectDrinkType String
    | SelectABVLevel String
    | SearchDrink String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks }, Cmd.none )

        SelectDrinkType drink_type ->
            ( { model | dtype_filter = drink_type }, Cmd.none )

        SelectABVLevel abv_level ->
            ( { model | abv_filter = abv_level }, Cmd.none )

        SearchDrink term ->
            ( { model | search_term = term }, Cmd.none )



-- VIEW


drink_types : List String
drink_types =
    [ "Beer", "Wine", "Spirits & Premixed", "Soft Drink", "Tonics & Mixers", "Cider" ]


abv_levels : List String
abv_levels =
    [ "0%", "0.05%", "0.5%", "1 - 2.5%", "2.5 - 8%" ]


view : Model -> Html Msg
view model =
    div [ class "mt6" ]
        [ div [ class "w-90 center" ]
            [ (renderSearch "Search Drinks..." SearchDrink)
            , (renderFilter "Drink Type" drink_types SelectDrinkType model.dtype_filter)
            , (renderFilter "ABV" abv_levels SelectABVLevel model.abv_filter)
            ]
        , div [ class "relative center w-90" ]
            [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    model.drinks
        |> List.filter (\d -> filterByType model d)
        |> List.filter (\d -> filterByABV model d)
        |> List.filter (\d -> filterByTerm model d)
        |> renderDrinks


filterByABV : Model -> Drink -> Bool
filterByABV model drink =
    case model.abv_filter of
        "0%" ->
            drink.abv == 0.0

        "0.05%" ->
            drink.abv == 0.05

        "0.5%" ->
            drink.abv == 0.5

        "1 - 2.5%" ->
            (drink.abv >= 1 && drink.abv <= 2.5)

        "2.5 - 8%" ->
            (drink.abv >= 2.5 && drink.abv <= 8)

        _ ->
            True


filterByType : Model -> Drink -> Bool
filterByType model drink =
    case String.toLower model.dtype_filter of
        "spirits and premixed" ->
            List.any (\t -> ("spirit" == String.toLower t || "premixed" == String.toLower t)) drink.drink_types

        _ ->
            List.any (\t -> String.toLower model.dtype_filter == String.toLower t) drink.drink_types
                || model.dtype_filter
                == ""


filterByTerm : Model -> Drink -> Bool
filterByTerm model drink =
    case model.search_term of
        "" ->
            True

        term ->
            (String.contains (String.toLower term) (String.toLower drink.name))
                || (String.contains (String.toLower term) (String.toLower drink.description))


renderDrinks : List Drink -> List (Html Msg)
renderDrinks drinks =
    if List.length drinks >= 1 then
        Array.fromList drinks
            |> Array.indexedMap drinkCard
            |> toList
    else
        [ div []
            [ p [class "tc"] [ text "Your search didn't return any drinks, change your filters and try again." ]
            ]
        ]



-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
