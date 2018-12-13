module SearchAll exposing (main)

import Array exposing (..)
import Browser
import DrinkCard exposing (drinkCard)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
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
    , term : Maybe String
    }


type alias Flags =
    { drinks : List SharedTypes.Drink
    , venues : List SharedTypes.Venue
    , term : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        term =
            if String.isEmpty flags.term then
                Nothing

            else
                Just flags.term
    in
    ( Model flags.drinks flags.venues term, Cmd.none )



-- Msg & UPDATE


type Msg
    = UpdateSearchTerm String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateSearchTerm term ->
            case term of
                "" ->
                    ( { model | term = Nothing }, Cmd.none )

                _ ->
                    ( { model | term = Just term }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        searchTerm =
            Maybe.withDefault "" model.term

        drinks =
            filterDrinks model.term model.drinks

        venues =
            filterVenues model.term model.venues

        totalDrinks =
            List.length drinks

        totalVenues =
            List.length venues
    in
    div [ class "mt5 mt6-ns" ]
        [ div [ class "relative w-90 center" ]
            [ input [ onInput UpdateSearchTerm, value searchTerm, placeholder "search drinks and venues" ] []
            , p [] [ text <| resultDescription totalDrinks totalVenues ]
            ]
        , div [ class "relative w-90 center" ]
            [ h1 [ class "f2 lh2" ] [ text "Drinks" ]
            , renderDrinks <| List.take 4 drinks
            , drinksPage totalDrinks 4 searchTerm
            , h1 [ class "f2 lh2" ] [ text "Venues" ]
            , renderVenues <| List.take 4 venues
            , venuesPage totalVenues 4 searchTerm
            ]
        ]


drinksPage : Int -> Int -> String -> Html Msg
drinksPage totalDrinks drinksDisplayed searchTerm =
    if (totalDrinks - drinksDisplayed) <= 0 then
        a [ href <| "/search/drinks?term=" ++ searchTerm ] [ text "View all drinks" ]

    else
        a [ href <| "/search/drinks?term=" ++ searchTerm ] [ text <| "See all (" ++ String.fromInt totalDrinks ++ ")" ]


venuesPage : Int -> Int -> String -> Html Msg
venuesPage totalVenues venuesDisplayed searchTerm =
    if (totalVenues - venuesDisplayed) <= 0 then
        a [ href <| "/search/venues?term=" ++ searchTerm ] [ text "View all venues" ]

    else
        a [ href <| "/search/venues?term=" ++ searchTerm ] [ text <| "See all (" ++ String.fromInt totalVenues ++ ")" ]


resultDescription : Int -> Int -> String
resultDescription totalDrinks totalVenues =
    "Found "
        ++ (String.fromInt <| totalDrinks)
        ++ (if totalDrinks == 1 then
                " drink, "

            else
                " drinks, "
           )
        ++ (String.fromInt <| totalVenues)
        ++ (if totalVenues == 1 then
                " venue"

            else
                " venues"
           )


filterDrinks : Maybe String -> List SharedTypes.Drink -> List SharedTypes.Drink
filterDrinks searchTerm drinks =
    drinks
        |> List.filter (SharedTypes.searchDrinkByTerm searchTerm)


filterVenues : Maybe String -> List SharedTypes.Venue -> List SharedTypes.Venue
filterVenues searchTerm venues =
    venues
        |> List.filter (SharedTypes.searchVenueByTerm searchTerm)


renderDrinks : List SharedTypes.Drink -> Html Msg
renderDrinks drinks =
    case drinks of
        [] ->
            p [] [ text "no drinks match the search term" ]

        _ ->
            div [ class "flex-ns flex-wrap justify-center pt3 pb4-ns db dib-ns" ]
                (Array.fromList drinks
                    |> Array.indexedMap drinkCard
                    |> toList
                )


renderVenues : List SharedTypes.Venue -> Html Msg
renderVenues venues =
    case venues of
        [] ->
            p [] [ text "no venues match the search term" ]

        _ ->
            div [] (Search.renderVenues venues)
