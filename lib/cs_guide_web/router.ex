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
    plug(CsGuideWeb.Plugs.StaticPages)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :admin do
    plug(:authenticate_user, admin: true)
  end

  pipeline :venue_id do
    plug(:assign_venue_id)
  end

  pipeline :venue_owner do
    plug(:authenticate_venue_owner)
  end

  scope "/", CsGuideWeb do
    # Use the default browser stack
    pipe_through([:browser, :venue_id])

    get("/", PageController, :index)
    post("/signup", SignupController, :create)

    get("/brands/:name", BrandController, :show)
    resources("/drinks", DrinkController, only: [:show])
    resources("/users", UserController, only: [:new, :create])
    get("/venues/:slug", VenueController, :show)

    resources("/sessions", SessionController, only: [:new, :create])

    get("/json_drinks", DrinkController, :json_index)
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
    resources("/brands", BrandController, except: [:show], param: "name")
    resources("/drinks", DrinkController, except: [:show])
    resources("/wholesalers", WholesalerController, except: [:show])
    resources("/retailers", RetailerController, except: [:show])
    resources("/static_pages", StaticPageController, except: [:show], param: "page_title")
    resources("/users", UserController, except: [:new, :create])
    resources("/venues", VenueController, only: [:delete, :index])
    resources("/wholesalers", WholesalerController, except: [:show])

    resources("/venue_types", VenueTypeController)
    resources("/drink_types", DrinkTypeController)
    resources("/drink_styles", DrinkStyleController)
    resources("/discount_codes", DiscountCodeController)

    get("/drinks/:id/add_photo", DrinkController, :add_photo)
    get("/brands/:name/add_photo", BrandController, :add_photo)

    post("/drinks/:id/", DrinkController, :upload_photo)
    post("/brands/:name/", BrandController, :upload_photo)
  end

  scope "/admin", CsGuideWeb do
    pipe_through([:browser, :venue_owner])
    get("/retailers/:id/add_drinks", RetailerController, :add_drinks)
    get("/venues/:slug/add_drinks", VenueController, :add_drinks, param: "slug")
    get("/venues/:slug/add_photo", VenueController, :add_photo)
    get("/wholesalers/:id/add_drinks", WholesalerController, :add_drinks)

    post("/venues/:id/", VenueController, :upload_photo)
    resources("/venues", VenueController, except: [:delete, :index], param: "slug")
  end

  scope "/csv", CsGuideWeb do
    pipe_through([:browser, :admin])
    get("/", CsvController, :export)
  end

  scope "/", CsGuideWeb do
    pipe_through(:browser)

    get("/:page_title", StaticPageController, :show)
    get("/*page_not_found", StaticPageController, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", CsGuideWeb do
  #   pipe_through :api
  # end
end
