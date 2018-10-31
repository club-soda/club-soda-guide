defmodule CsGuideWeb.Router do
  use CsGuideWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", CsGuideWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/signup", SignupController, :create)

    resources("/users", UserController)
    resources("/venues", VenueController)
    resources("/venue_types", VenueTypeController)
    resources("/drink_types", DrinkTypeController)
    resources("/drinks", DrinkController)
    resources("/brands", BrandController)
    resources("/drink_styles", DrinkStyleController)

    get("/json_drinks", DrinkController, :json_index)
    get("/venues/:id/add_drinks", VenueController, :add_drinks)
    get("/venues/:id/add_photo", VenueController, :add_photo)
    post("/venues/:id/", VenueController, :upload_photo)
  end

  scope "/search", CsGuideWeb do
    pipe_through(:browser)

    resources("/drinks", SearchDrinkController, only: [:index])
    resources("/venues", SearchVenueController, only: [:index])
  end

  # Other scopes may use custom stacks.
  # scope "/api", CsGuideWeb do
  #   pipe_through :api
  # end
end
