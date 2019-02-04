module Abv exposing (AbvFilter, AbvSubFilters, IdAbvFilter, abvFilters, getAbvFilterById, getAbvFilterId, getAbvFilterName)


type alias IdAbvFilter =
    String


type alias AbvFilter =
    ( String, IdAbvFilter, AbvSubFilters )


type AbvSubFilters
    = AbvSubFilters (List AbvFilter)


abvFilters : List AbvFilter
abvFilters =
    [ ( "< 0.05%", "0", AbvSubFilters [] )
    , ( "0.05% - 0.5%", "1", AbvSubFilters [] )
    , ( "0.51% - 1%", "2", AbvSubFilters [] )
    , ( "1.1% - 3%", "3", AbvSubFilters [] )
    , ( "3.1% +", "4", AbvSubFilters [] )
    ]


getAbvFilterName : AbvFilter -> String
getAbvFilterName ( name, _, _ ) =
    name


getAbvFilterId : AbvFilter -> IdAbvFilter
getAbvFilterId ( _, idFilter, _ ) =
    idFilter


getAbvFilterById : IdAbvFilter -> List AbvFilter -> Maybe AbvFilter
getAbvFilterById filterId filters =
    filters
        |> List.filter (\( _, id, _ ) -> filterId == id)
        |> List.head
