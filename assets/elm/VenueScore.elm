module VenueScore exposing
    ( IdVenueScore
    , VenueScoreFilter
    , VenueScoreSubFilters
    , getVenueScoreFilterId
    , getVenueScoreFilterName
    , getVenueScoreFitlerById
    , venueScoreFilters
    )


type alias IdVenueScore =
    String


type alias VenueScoreFilter =
    ( String, IdVenueScore, VenueScoreSubFilters )


type VenueScoreSubFilters
    = VenueScoreSubFilters (List VenueScoreFilter)


venueScoreFilters : List VenueScoreFilter
venueScoreFilters =
    [ ( "0", "0", VenueScoreSubFilters [] )
    , ( "1", "1", VenueScoreSubFilters [] )
    , ( "2", "2", VenueScoreSubFilters [] )
    , ( "3", "3", VenueScoreSubFilters [] )
    , ( "4", "4", VenueScoreSubFilters [] )
    , ( "5", "5", VenueScoreSubFilters [] )
    ]


getVenueScoreFilterName : VenueScoreFilter -> String
getVenueScoreFilterName ( name, _, _ ) =
    name


getVenueScoreFilterId : VenueScoreFilter -> IdVenueScore
getVenueScoreFilterId ( _, idFilter, _ ) =
    idFilter


getVenueScoreFitlerById : IdVenueScore -> List VenueScoreFilter -> Maybe VenueScoreFilter
getVenueScoreFitlerById filterId filters =
    filters
        |> List.filter (\( _, id, _ ) -> filterId == id)
        |> List.head
