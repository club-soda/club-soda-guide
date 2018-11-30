var search = document.getElementById('search');
if (search) {
  var drink_type = window.location.search.slice(1).split("=")[1].replace(/_/g, " ") || "default";
  var searchApp;
  searchApp = Elm.Search.init({
    node: search, flags: Object.assign({}, {dtype_filter : drink_type})
  })
}

var searchVenue = document.getElementById('search-venue');
if (searchVenue) {
  Elm.SearchVenue.init({
    node: searchVenue, flags: {venues: venues}
  })
}
