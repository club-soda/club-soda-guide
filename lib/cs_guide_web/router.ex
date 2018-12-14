defmodule CsGuideWeb.Router do
  use CsGuideWeb, :router

  import CsGuideWeb.Plugs.Auth

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(CsGuideWeb.Plugs.Auth)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin do
    plug(:authenticate_user, admin: true)
  end

  scope "/", CsGuideWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    post("/signup", SignupController, :create)

    resources("/users", UserController, only: [:new, :create])
    resources("/venues", VenueController, only: [:show])
    resources("/drinks", DrinkController, only: [:show])
    get("/brands/:name", BrandController, :show)

    resources("/sessions", SessionController, only: [:new, :create])

    get("/json_drinks", DrinkController, :json_index)
    get("/:page_name", StaticPageController, :show)
  end

  scope "/search", CsGuideWeb do
    pipe_through(:browser)

    resources("/drinks", SearchDrinkController, only: [:index])
    resources("/venues", SearchVenueController, only: [:index])
    resources("/all", SearchAllController, only: [:index])
  end

  scope "/admin", CsGuideWeb do
    pipe_through([:browser, :admin])

    resources("/", AdminController, only: [:index])
    resources("/static_pages", StaticPageController, except: [:show])
    resources("/users", UserController, except: [:new, :create])
    resources("/venues", VenueController, except: [:show])
    resources("/retailers", RetailerController, except: [:show])
    resources("/drinks", DrinkController, except: [:show])
    resources("/brands", BrandController, except: [:show], param: "name")

    resources("/venue_types", VenueTypeController)
    resources("/drink_types", DrinkTypeController)
    resources("/drink_styles", DrinkStyleController)

    get("/venues/:id/add_drinks", VenueController, :add_drinks)
    get("/venues/:id/add_photo", VenueController, :add_photo)
    get("/drinks/:id/add_photo", DrinkController, :add_photo)
    get("/brands/:name/add_photo", BrandController, :add_photo)

    post("/venues/:id/", VenueController, :upload_photo)
    post("/drinks/:id/", DrinkController, :upload_photo)
    post("/brands/:name/", BrandController, :upload_photo)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CsGuideWeb do
  #   pipe_through :api
  # end
end
