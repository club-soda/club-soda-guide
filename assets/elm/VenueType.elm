module VenueType exposing
    ( IdVenueType
    , VenueTypeFilter
    , VenueTypeSubFilters
    , getVenueTypeFilterId
    , getVenueTypeFilterName
    , getVenueTypeFilters
    , getVenueTypeFitlerById
    )


type alias IdVenueType =
    String


type alias VenueTypeFilter =
    ( String, IdVenueType, VenueTypeSubFilters )


type VenueTypeSubFilters
    = VenueTypeSubFilters (List VenueTypeFilter)


getVenueTypeFilters : List String -> List VenueTypeFilter
getVenueTypeFilters venueTypes =
    venueTypes
        |> List.map (\vt -> ( vt, String.toLower vt, VenueTypeSubFilters [] ))


getVenueTypeFilterName : VenueTypeFilter -> String
getVenueTypeFilterName ( name, _, _ ) =
    name


getVenueTypeFilterId : VenueTypeFilter -> IdVenueType
getVenueTypeFilterId ( _, idFilter, _ ) =
    idFilter


getVenueTypeFitlerById : IdVenueType -> List VenueTypeFilter -> Maybe VenueTypeFilter
getVenueTypeFitlerById filterId filters =
    filters
        |> List.filter (\( _, id, _ ) -> filterId == id)
        |> List.head
