module SearchDrink exposing (main)

import Array
import Browser
import Criteria
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Search exposing (renderFilter, renderSearch)
import Set
import SharedTypes exposing (Drink)
import TypeAndStyle
    exposing
        ( Filter
        , FilterType
        , SubFilters(..)
        , drinksTypeAndStyle
        , getFilterById
        , getFilterId
        , getFilterName
        , getFilterType
        )



-- MODEL


type alias Model =
    { drinks : List Drink
    , drinkFilters : Criteria.State
    , abvFilter : String
    , searchTerm : Maybe String
    }


type alias Flags =
    { drinks : List Drink
    , dtype_filter : String
    , term : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        dtype_filter =
            if flags.dtype_filter == "none" then
                []

            else
                [ flags.dtype_filter ]
    in
    ( { drinks = flags.drinks
      , drinkFilters = Criteria.init dtype_filter
      , abvFilter = ""
      , searchTerm =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = SelectABVLevel String
    | SearchDrink String
    | UpdateFilters Criteria.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectABVLevel abv_level ->
            ( { model | abvFilter = abv_level }, Cmd.none )

        SearchDrink term ->
            let
                searchTerm =
                    if String.isEmpty term then
                        Nothing

                    else
                        Just term
            in
            ( { model | searchTerm = searchTerm }, Cmd.none )

        UpdateFilters state ->
            ( { model | drinkFilters = state }, Cmd.none )



-- VIEW


getSubFilters : Filter -> List Filter
getSubFilters ( _, _, SubFilters subFilters ) =
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
                , filterDivAttrs = filterDivAttrs
                , buttonAttrs = buttonAttrs
                , filterLabelAttrs = filterLabelAttrs
                , filterNameAttrs = filterNameAttrs
                , filterImgToggleAttrs = filterImgToggleAttrs
            }
        }


mainDivAttrs : List (Attribute Msg)
mainDivAttrs =
    [ class "relative bg-white dib z-1" ]


filtersDivAttrs : List (Attribute Msg)
filtersDivAttrs =
    [ class "absolute w-200 bg-white shadow-1 bw1 dropdown" ]


filterDivAttrs : Filter -> Criteria.State -> List (Attribute Msg)
filterDivAttrs _ _ =
    [ style "padding" "0.5rem 0" ]


buttonAttrs : List (Attribute Msg)
buttonAttrs =
    [ class "f6 lh6 bg-white b--cs-gray br2 bw1 pv2 ph3 dib w6 cs-gray mr2" ]


filterLabelAttrs : Filter -> Criteria.State -> List (Attribute Msg)
filterLabelAttrs filter stateCriteria =
    [ class "pl2 pointer lh5 f5" ]


filterNameAttrs : Filter -> Criteria.State -> List (Attribute Msg)
filterNameAttrs _ _ =
    [ style "margin-left" "1rem" ]


filterImgToggleAttrs : List (Attribute Msg)
filterImgToggleAttrs =
    [ class "fr pointer", style "padding-right" "0.5rem" ]


abv_levels : List String
abv_levels =
    [ "<0.05%", "0.05% - 0.5%", "0.51% - 1%", "1.1% - 3%", "3.1% +" ]


view : Model -> Html Msg
view model =
    div [ class "mt5 mt6-ns" ]
        [ div [ class "w-90 center" ]
            [ renderSearch "Search Drinks..." (Maybe.withDefault "" model.searchTerm) SearchDrink
            , Criteria.view criteriaConfig model.drinkFilters drinksTypeAndStyle
            , renderFilter "ABV" abv_levels SelectABVLevel model.abvFilter
            ]
        , div [ class "relative center w-90" ]
            [ div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    model.drinks
        |> List.filter (\d -> filterByTypeAndStyle (Set.toList <| Criteria.selectedIdFilters model.drinkFilters) d)
        |> List.filter (\d -> filterByABV model d)
        |> List.filter (\d -> SharedTypes.searchDrinkByTerm model.searchTerm d)
        |> renderDrinks


filterByABV : Model -> Drink -> Bool
filterByABV model drink =
    case model.abvFilter of
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


filterByTypeAndStyle : List String -> Drink -> Bool
filterByTypeAndStyle filters drink =
    case filters of
        [] ->
            True

        _ ->
            filters
                |> List.map
                    (\f ->
                        case getFilterById f drinksTypeAndStyle of
                            Nothing ->
                                False

                            Just ( TypeAndStyle.Type, _, _ ) ->
                                List.member f drink.drink_types

                            Just ( TypeAndStyle.Style, _, _ ) ->
                                List.member f drink.drink_styles
                    )
                |> List.any ((==) True)


renderDrinks : List Drink -> List (Html Msg)
renderDrinks drinks =
    if List.length drinks >= 1 then
        Array.fromList drinks
            |> Array.indexedMap drinkCard
            |> Array.toList

    else
        [ div []
            [ p [ class "tc" ] [ text "Your search didn't return any drinks, change your filters and try again." ]
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
