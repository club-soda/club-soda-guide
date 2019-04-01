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
    plug(:authenticate_site_admin)
  end

  pipeline :venue_owner do
    plug(:authenticate_venue_owner)
  end

  scope "/", CsGuideWeb do
    # Use the default browser stack
    pipe_through([:browser])

    get("/", PageController, :index)
    post("/signup", SignupController, :create)

    get("/brands/:slug", BrandController, :show)
    resources("/drinks", DrinkController, only: [:show])
    resources("/users", UserController, only: [:new, :create])
    get("/venues/:slug", VenueController, :show)

    resources("/sessions", SessionController, only: [:new, :create, :delete])

    get("/json_drinks", DrinkController, :json_index)
    get("/json_venue_images", VenueController, :json_index)
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
    resources("/brands", BrandController, except: [:show, :delete], param: "slug")
    resources("/brands", BrandController, only: [:delete], param: "entry_id")
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
    resources("/sponsor", SponsorController)
    resources("/searchlog", SearchLogController, only: [:index])

    get("/drinks/:id/add_photo", DrinkController, :add_photo)
    get("/brands/:slug/add_cover_photo", BrandController, :add_cover_photo)
    get("/brands/:slug/add_photo", BrandController, :add_photo)

    post("/drinks/:id/", DrinkController, :upload_photo)
    post("/brands/:slug/", BrandController, :upload_photo)
  end

  scope "/admin", CsGuideWeb do
    # Leaving this with just the :browser pipeline for the moment. Going to make
    # a new venue_owner pipeline
    pipe_through([:browser])
    # pipe_through([:browser, :venue_owner])
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
end
