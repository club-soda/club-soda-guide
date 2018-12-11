var search = document.getElementById('search');
if (search) {
  var params = window.location.search.slice(1).split("=")[1];
  var drink_type = (params && params.replace(/_/g, " ")) || "default";
  var searchApp;
  searchApp = Elm.SearchDrink.init({
    node: search, flags: Object.assign({}, { dtype_filter: drink_type })
  })
}

var searchVenue = document.getElementById('search-venue');
if (searchVenue) {
  Elm.SearchVenue.init({
    node: searchVenue, flags: { venues: venues }
  })
}

var searchAll = document.getElementById('search-all');
if (searchAll) {
  Elm.SearchAll.init({
    node: searchAll, flags: { drinks: drinks, venues: venues }
  })
}
