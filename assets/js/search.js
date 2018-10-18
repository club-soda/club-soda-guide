var drink_type = window.location.search.slice(1).split("=")[1]

  var search = document.getElementById('search');
  var searchApp;
  if (search) {
    searchApp = Elm.Search.init({
      node: search, flags: Object.assign({}, {dtype_filter : drink_type})
    })
  }
