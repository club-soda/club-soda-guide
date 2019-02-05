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
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { images = []
      , carouselIndex = 1
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
            ( { model | images = images }, Cmd.none )

        CarouselLeft ->
            ( { model | carouselIndex = modBy 4 model.carouselIndex + 1 }, Cmd.none )

        CarouselRight ->
            ( { model | carouselIndex = modBy 4 model.carouselIndex - 1 }, Cmd.none )

        Swipe dir ->
            let
                newIndex =
                    case dir of
                        "right" ->
                            modBy 4 model.carouselIndex - 1

                        "left" ->
                            modBy 4 model.carouselIndex + 1

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
        [ img [ src "/images/up-chevron.svg", alt "left arrow", class "dn db-ns f1 b pointer absolute-vertical-center left-2 rotate-270 h1", onClick CarouselLeft ] []
        , div [ class "w-100 bg-venue center dn db-ns overflow-hidden" ]
            (renderImagesCarousel model 0)
        , div [ class "flex-wrap w-90 center db dn-ns", id "carousel" ]
            (renderImagesCarousel model 0)
        , img [ src "/images/up-chevron.svg", alt "right arrow", onClick CarouselRight, class "dn db-ns f1 b pointer absolute-vertical-center right-2 rotate-90 h1" ] []
        ]


renderImagesCarousel : Model -> Int -> List (Html Msg)
renderImagesCarousel model displayXImages =
    List.range model.carouselIndex (model.carouselIndex + displayXImages)
        |> List.map (\index -> getImageByIndex model <| modBy 4 index)
        |> List.indexedMap displayImage


displayImage : Int -> VenueImage -> Html msg
displayImage index venueImage =
    div []
        [ h1 [] [ text venueImage.photoUrl ]
        , img [ class "w-100", src venueImage.photoUrl ] []
        ]


getImageByIndex : Model -> Int -> VenueImage
getImageByIndex model index =
    Array.fromList model.images
        |> Array.get index
        |> Maybe.withDefault (VenueImage "default" 1 1)
