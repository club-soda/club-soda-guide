module SearchDrink exposing (main)

import Array
import Browser
import Criteria
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (Decoder, at, field, float, list, map, string)
import Search exposing (renderFilter, renderSearch)
import Set
import SharedTypes exposing (Drink)
import TypeAndStyle exposing (Filter, SubFilters(..), drinksTypeAndStyle)



-- MODEL


type alias Model =
    { drinks : List Drink
    , drink_filters : Criteria.State
    , abv_filter : String
    , search_term : String
    , gettingDrinks : Bool
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
      , drink_filters = Criteria.init
      , abv_filter = ""
      , search_term = ""
      , gettingDrinks = True
      }
    , getDrinks
    )


onChange : (String -> msg) -> Attribute msg
onChange msgConstructor =
    Html.Events.on "change" <| Json.map msgConstructor <| Json.at [ "target", "value" ] Json.string


getDrinks : Cmd Msg
getDrinks =
    Http.get "/json_drinks" drinksDecoder |> Http.send ReceiveDrinks


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
    | SelectABVLevel String
    | SearchDrink String
    | UpdateFilters Criteria.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks, gettingDrinks = False }, Cmd.none )

        -- SelectDrinkType drink_type ->
        --     ( { model | dtype_filter = drink_type }, Cmd.none )
        SelectABVLevel abv_level ->
            ( { model | abv_filter = abv_level }, Cmd.none )

        SearchDrink term ->
            ( { model | search_term = term }, Cmd.none )

        UpdateFilters state ->
            ( { model | drink_filters = state }, Cmd.none )



-- VIEW


getFilterName : Filter -> String
getFilterName ( filter, _ ) =
    filter


getFilterId : Filter -> String
getFilterId ( filter, _ ) =
    filter


getSubFilters : Filter -> List Filter
getSubFilters ( _, SubFilters subFilters ) =
    subFilters


criteriaConfig : Criteria.Config Msg Filter
criteriaConfig =
    let
        defaulCustomisations =
            Criteria.defaultCustomisations
    in
    Criteria.customConfig
        { title = "Drink Type"
        , toMsg = UpdateFilters
        , toId = getFilterId
        , toString = getFilterName
        , getSubFilters = getSubFilters
        , customisations =
            { defaulCustomisations
                | mainDivAttrs = mainDivAttrs
                , filtersDivAttrs = filtersDivAttrs
                , buttonAttrs = buttonAttrs
                , filterLabelAttrs = filterLabelAttrs
            }
        }


mainDivAttrs : List (Attribute Msg)
mainDivAttrs =
    [ class "relative bg-white dib z-max" ]


filtersDivAttrs : List (Attribute Msg)
filtersDivAttrs =
    [ class "absolute w100 ba bw1" ]


buttonAttrs : List (Attribute Msg)
buttonAttrs =
    [ class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6 cs-gray mr2" ]


filterLabelAttrs : Filter -> Criteria.State -> List (Attribute Msg)
filterLabelAttrs filter stateCriteria =
    [ class "pa2 pointer" ]


abv_levels : List String
abv_levels =
    [ "<0.05%", "0.05% - 0.5%", "0.51% - 1%", "1.1% - 3%", "3.1% +" ]


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ div [ class "w-90 center" ]
            [ renderSearch "Search Drinks..." SearchDrink
            , Criteria.view criteriaConfig model.drink_filters drinksTypeAndStyle
            , renderFilter "ABV" abv_levels SelectABVLevel model.abv_filter
            ]
        , div [ class "relative center w-90" ]
            [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    model.drinks
        |> List.filter (\d -> filterByType (Set.toList <| Criteria.selectedIdFilters model.drink_filters) d)
        |> List.filter (\d -> filterByABV model d)
        |> List.filter (\d -> filterByTerm model d)
        |> renderDrinks model.gettingDrinks


filterByABV : Model -> Drink -> Bool
filterByABV model drink =
    case model.abv_filter of
        "<0.05%" ->
            drink.abv < 0.05

        "0.05% - 0.5%" ->
            drink.abv >= 0.05 && drink.abv <= 0.5

        "0.51% - 1%" ->
            drink.abv >= 0.51 && drink.abv <= 1

        "1.1% - 3%" ->
            drink.abv >= 1.1 && drink.abv <= 3

        "3.1% +" ->
            drink.abv > 3

        _ ->
            True


filterByType : List String -> Drink -> Bool
filterByType filters drink =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map (\f -> List.member f drink.drink_types)
                |> List.any ((==) True)


filterByTerm : Model -> Drink -> Bool
filterByTerm model drink =
    case model.search_term of
        "" ->
            True

        term ->
            String.contains (String.toLower term) (String.toLower drink.name)
                || String.contains (String.toLower term) (String.toLower drink.description)


renderDrinks : Bool -> List Drink -> List (Html Msg)
renderDrinks gettingDrinks drinks =
    if List.length drinks >= 1 then
        Array.fromList drinks
            |> Array.indexedMap drinkCard
            |> Array.toList

    else
        [ div []
            [ if gettingDrinks then
                p [ class "tc" ] [ text "Searching drinks..." ]

              else
                p [ class "tc" ] [ text "Your search didn't return any drinks, change your filters and try again." ]
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
