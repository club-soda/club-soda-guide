port module VenueCarousel exposing (HttpData, Model, Msg(..), getImageByIndex, getVenueImages, imageDecoder, imagesDecoder, init, main, renderImagesCarousel, subscriptions, swipeVenue, update, view)

import Array exposing (..)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (..)
import Json.Decode.Pipeline exposing (..)
import SharedTypes exposing (VenueImage)



-- MAIN


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }



-- MODEL


getVenueImages : Cmd Msg
getVenueImages =
    Http.get "/json_venue_images" imagesDecoder |> Http.send ReceiveImages


imagesDecoder : Decoder (List VenueImage)
imagesDecoder =
    Decode.list imageDecoder


imageDecoder : Decoder VenueImage
imageDecoder =
    Decode.map3 VenueImage
        (field "photoUrl" string)
        (field "photoNumber" int)
        (field "venueId" int)


type alias HttpData data =
    Result Http.Error data


type alias Model =
    { images : List VenueImage
    , carouselIndex : Int
    , numberImages : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { images = []
      , carouselIndex = 0
      , numberImages = 1
      }
    , getVenueImages
    )



-- UPDATE


type Msg
    = ReceiveImages (HttpData (List VenueImage))
    | CarouselRight
    | CarouselLeft
    | Swipe String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveImages (Err _) ->
            ( model, Cmd.none )

        ReceiveImages (Ok images) ->
            let
                numberImages =
                    List.length images
            in
            ( { model | images = images, numberImages = numberImages }, Cmd.none )

        CarouselLeft ->
            ( { model | carouselIndex = modBy model.numberImages model.carouselIndex - 1 }, Cmd.none )

        CarouselRight ->
            ( { model | carouselIndex = modBy model.numberImages model.carouselIndex + 1 }, Cmd.none )

        Swipe dir ->
            let
                newIndex =
                    case dir of
                        "right" ->
                            modBy model.numberImages model.carouselIndex + 1

                        "left" ->
                            modBy model.numberImages model.carouselIndex - 1

                        _ ->
                            model.carouselIndex
            in
            ( { model | carouselIndex = newIndex }, Cmd.none )


port swipeVenue : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    swipeVenue Swipe



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "relative" ]
        [ img [ src "/images/left-chevron.svg", alt "left arrow", class "dn db-ns b pointer absolute-vertical-center left-2 w1", onClick CarouselLeft ] []
        , div [ class "w-100 center dn db-ns" ]
            (renderImagesCarousel model)
        , div [ class "flex-wrap w-90 center db dn-ns", id "carousel" ]
            (renderImagesCarousel model)
        , img [ src "/images/right-chevron.svg", alt "right arrow", onClick CarouselRight, class "dn db-ns b pointer absolute-vertical-center right-2 w1" ] []
        ]


renderImagesCarousel : Model -> List (Html Msg)
renderImagesCarousel model =
    List.range model.carouselIndex model.carouselIndex
        |> List.map (\index -> getImageByIndex model <| modBy model.numberImages index)
        |> List.map displayImage


displayImage : VenueImage -> Html msg
displayImage venueImage =
    if String.isEmpty venueImage.photoUrl then
        div [] []

    else
        div []
            [ h1 [] [ text venueImage.photoUrl ]
            , h1 [] [ text <| String.fromInt <| venueImage.photoNumber ]
            , img [ class "w-100 bg-venue", src venueImage.photoUrl ] []
            ]


getImageByIndex : Model -> Int -> VenueImage
getImageByIndex model index =
    let
        _ =
            Debug.log "set default 5" index
    in
    Array.fromList model.images
        |> Array.get index
        |> Maybe.withDefault (VenueImage "" 0 1)
