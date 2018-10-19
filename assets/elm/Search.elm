module Search exposing (..)

import Browser
import Http
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Array exposing (..)


-- MODEL


type alias Drink =
    { name : String
    , brand : String
    , abv : Float
    , drink_types : List String
    }


type alias Model =
    { drinks : List Drink
    , dtype_filter : String
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
    Json.map4 Drink
        (field "name" string)
        (field "brand" string)
        (field "abv" float)
        (field "drink_types" (Json.list string))



-- UPDATE


type Msg
    = ReceiveDrinks (HttpData (List Drink))
    | SelectDrinkType String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDrinks (Err _) ->
            ( model, Cmd.none )

        ReceiveDrinks (Ok drinks) ->
            ( { model | drinks = drinks }, Cmd.none )

        SelectDrinkType drink_type ->
            ( { model | dtype_filter = drink_type }, Cmd.none )



-- VIEW
drink_types : List String
drink_types =
    [ "Beer", "Wine", "Spirits and Mixers", "Soft Drinks", "Flavoured Tonics", "Ciders" ]

view : Model -> Html Msg
view model =
    div [ class "mt6" ]
        [ (renderFilters model "Drink Type" drink_types)
        , div [ class "relative" ]
            [ div [ class "flex-ns flex-wrap justify-center pv4-ns db dib-ns" ]
                (filterDrinks model)
            ]
        ]


filterDrinks : Model -> List (Html Msg)
filterDrinks model =
    List.filter (\d -> filterByType model d) model.drinks
        |> renderDrinks


filterByType : Model -> Drink -> Bool
filterByType model drink =
  case String.toLower model.dtype_filter of
  "spirits and mixers" ->
    List.any (\t -> ("spirit" == String.toLower t || "mixer" == String.toLower t) )drink.drink_types
  _ ->
    List.any (\t -> String.toLower model.dtype_filter == String.toLower t) drink.drink_types
        || model.dtype_filter
        == ""


renderDrinks : List Drink -> List (Html Msg)
renderDrinks drinks =
    Array.fromList drinks
        |> Array.indexedMap
            (\index d ->
                div
                    [ class "w-third-m w-20-l shadow-4 br2 tr pb3 mh3 mv3 relative" ]
                    [ div [ class "card-front-contents" ]
                        [ div [ class "bb b--cs-light-pink bw3 mb3 tl h-27rem" ]
                            [ h4 [ class "f4 lh4 pa3 shadow-4 br2 mt4 mb1 mh4 tc bg-sheer-white absolute top-1" ] [ text <| d.brand ++ " " ++ d.name ]
                            , img [ src "https://res.cloudinary.com/ratebeer/image/upload/w_250,c_limit/beer_117796.jpg", alt "Photo of drink", class "w-5rem db center pt4" ] []
                            , p [ class "bg-cs-mint br2 ph3 pv2 white shadow-4 ml4 mv4 dib" ] [ text <| String.fromFloat d.abv ++ "% ABV" ]
                            ]
                        ]
                    , input [ type_ "checkbox", name "card-front", id <| "display-back-" ++ String.fromInt index, class "display-back dn" ] []
                    , label [ for <| "display-back-" ++ String.fromInt index, class "cs-mid-blue f5 lh5 tr pr4 underline" ] []
                    , div [ class "card-back-contents dn absolute top-0 left-0 bg-white pt3 ph3" ]
                        [ div [ class "tl h-25rem" ]
                            [ div [ class "bb b--pink mt2 mh2 pb3 center" ]
                                [ h4 [ class "f4 lh4 mb1" ] [ text d.name ]
                                , p [ class "f5 lh5 mv1" ] [ text "by" ]
                                , a [ class "f4 lh4 cs-mid-blue mv1", href "#" ] [ text d.brand ]
                                ]
                            , div [ class "flex flex-wrap" ]
                                [ p [ class "w-50 pv2 dib" ] [ text "Drink Category" ]
                                , p [ class "w-50 pv2 dib" ] [ text <| String.fromFloat d.abv ++ "% ABV" ]
                                ]
                            , p [ class "pv2" ]
                                [ text "Drink description text Drink description \n                                text Drink description text Drink description \n                                text Drink description text"
                                ]
                            ]
                        ]
                    ]
            )
        |> toList


renderFilters : Model -> String -> List String -> Html Msg
renderFilters model defaultTitle dropdownItems =
    div [ class "w-90 center" ]
        [ select
            [ onChange SelectDrinkType
            , class "f6 lh6 cs-light-gray bg-white b--cs-light-gray br2 bw1 pv2 pl2 dib w6 mb2"
            ]
            ([ option [ Html.Attributes.value "" ] [ text defaultTitle ] ]
                ++ List.map (\dropdownItem -> renderDropdownItems model dropdownItem) dropdownItems
            )
        ]

renderDropdownItems : Model -> String -> Html Msg
renderDropdownItems model dropdownItem =
  if (String.toLower dropdownItem) == (String.toLower model.dtype_filter) then
    option [ Html.Attributes.value dropdownItem, Html.Attributes.selected True]
    [ text dropdownItem ]
  else
    option [ Html.Attributes.value dropdownItem ] [ text dropdownItem ]

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
