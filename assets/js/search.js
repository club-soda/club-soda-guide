
  var search = document.getElementById('search');
  if (search) {
    var params = window.location.search.slice(1).split("=")[1];
    var drink_type = (params && params.replace(/_/g, " ")) || "default";
    Elm.Search.init({
      node: search, flags: Object.assign({}, {dtype_filter : drink_type})
    })
  }
