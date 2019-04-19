defmodule CsGuideWeb.VenueController do
  use CsGuideWeb, :controller

  alias CsGuide.Resources.{Venue, Drink, Brand}
  alias CsGuide.Images.VenueImage
  alias CsGuideWeb.SearchVenueController
  alias CsGuide.Repo
  alias CsGuide.Accounts.{User, VenueUser}

  @mailer Application.get_env(:cs_guide, :mailer) || CsGuide.Mailer
  @ten_days 864000 # ten days in seconds

  import Ecto.Query, only: [from: 2, subquery: 1]

  def index(conn, %{"date_order" => _date_order}) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "wholesaler" || String.downcase(type.name) == "retailer"
        end)
      end)
      |> sort_venues_by_date

    render(conn, "index.html", venues: venues)
  end

  def index(conn, _params) do
    venues =
      Venue.all()
      |> Venue.preload(:venue_types)
      |> Enum.filter(fn v ->
        !Enum.find(v.venue_types, fn type ->
          String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
        end)
      end)
      |> Enum.sort_by(& &1.venue_name)

    render(conn, "index.html", venues: venues)
  end

  def new(conn, _params) do
    changeset = Venue.changeset(%Venue{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"venue" => venue_params}) do
    changeset = Venue.changeset(%Venue{}, venue_params)

    case Venue.insert(changeset, venue_params) do
      {:ok, venue} ->
        conn
        |> put_flash(:info, "Venue created successfully.")
        |> redirect(to: venue_path(conn, :show, venue.slug))

      {:error, %Ecto.Changeset{} = changeset} ->
        changeset =
          CsGuide.ChangesetHelpers.update_error_msg(changeset, Fields.Url, "should be a url")

        render(conn, "new.html", changeset: changeset)
    end
  end

  def json_index(conn, _params) do
    slug =
      conn.req_headers
      |> Enum.into(%{})
      |> Map.get("referer")
      |> String.split("/")
      |> List.last()

    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload(
        drinks: [:brand, :drink_types, :drink_styles, :drink_images],
        venue_types: [],
        venue_images: [],
        discount_codes: []
      )
      |> sortImagesByMostRecent()

    venue_images =
      [
        getPhotoOfPhotoNumber(venue, 1),
        getPhotoOfPhotoNumber(venue, 2),
        getPhotoOfPhotoNumber(venue, 3),
        getPhotoOfPhotoNumber(venue, 4)
      ]
      |> Enum.filter(fn i -> i != false end)

    json(
      conn,
      venue_images
      |> Enum.slice(0, 4)
      |> Enum.map(fn i ->
        %{
          photoUrl:
            "https://s3-eu-west-1.amazonaws.com/#{Application.get_env(:ex_aws, :bucket)}/#{
              i.entry_id
            }",
          photoNumber: i.photo_number,
          venueId: i.venue_id
        }
      end)
    )
  end

  def show(conn, %{"slug" => slug}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload(
        drinks: [:brand, :drink_types, :drink_styles, :drink_images],
        venue_types: [],
        venue_images: [],
        discount_codes: []
      )

    venue = sortImagesByMostRecent(venue)

    nearby_venues =
      getVenueCardsByLatLong(venue.lat, venue.long, venue.venue_name)
      |> Enum.take(4)
      |> Enum.map(&sortImagesByMostRecent/1)
      |> Enum.map(&SearchVenueController.selectPhotoNumber1/1)

    current_user_able_to_edit_venue = can_current_user_edit_venue?(conn, venue)

    if venue != nil do
      render(conn, "show.html",
        venue: venue,
        is_authenticated: current_user_able_to_edit_venue,
        nearby_venues: nearby_venues
      )
    else
      conn
      |> put_view(CsGuideWeb.StaticPageView)
      |> render("404.html")
    end
  end

  def edit(conn, %{"slug" => slug}) do
    venue = Venue.get_by(slug: slug) |> Venue.preload(:venue_types)
    changeset = Venue.changeset(venue)
    render(conn, "edit.html", venue: venue, changeset: changeset)
  end

  def update(conn, %{
        "slug" => slug,
        "venue" => venue = %{"drinks" => drinks, "num_cocktails" => num_cocktails}
      })
      when map_size(venue) <= 2 do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload([:venue_types, :venue_images, :discount_codes, :drinks, :users])

    venue_params =
      venue
      |> Map.from_struct()
      |> Map.drop([:users])
      |> Map.put(:drinks, drinks)
      |> Map.put(:num_cocktails, num_cocktails)

    do_update(conn, venue, venue_params)
  end

  def update(conn, %{"slug" => slug, "venue" => venue_params}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload([:venue_types, :venue_images, :discount_codes, :drinks, :users])

    venue_params = Map.put(venue_params, "drinks", venue.drinks)

    case Venue.update(venue, venue_params) do
      {:ok, _venue} ->
        conn
        |> put_flash(:info, "Venue updated successfully.")
        |> redirect(to: venue_path(conn, :show, Map.get(venue_params, "slug", slug)))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end

  def add_drinks(conn, %{"slug" => slug}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload(drinks: [:brand], venue_types: [])

    brands = Brand.all() |> Brand.preload(:drinks)

    changeset = Venue.changeset(venue)

    render(conn, "add_drinks.html",
      brands: brands,
      current_drinks: Enum.map(venue.drinks, fn d -> d.entry_id end),
      changeset: changeset,
      action: venue_path(conn, :update, slug)
    )
  end

  def add_photo(conn, %{"slug" => slug}) do
    venue =
      Venue.get_by(slug: slug)
      |> Venue.preload([:venue_images])
      |> sortImagesByMostRecent()

    render(conn, "add_photo.html",
      id: venue.entry_id,
      venue_images: venue.venue_images
    )
  end

  def upload_photo(conn, params) do
    venue =
      Venue.get(params["id"])
      |> Venue.preload([:venue_images])
      |> sortImagesByMostRecent()

    photo_number =
      cond do
        params["1"] ->
          1

        params["2"] ->
          2

        params["3"] ->
          3

        params["4"] ->
          4

        true ->
          1
      end

    CsGuide.Repo.transaction(fn ->
      with {:ok, venue_image} <-
             VenueImage.insert(%{venue: params["id"], photo_number: photo_number}),
           {:ok, _} <- CsGuide.Resources.upload_photo(params, venue_image.entry_id) do
        {:ok, venue_image}
      else
        val ->
          CsGuide.Repo.rollback(val)
      end
    end)
    |> case do
      {:ok, _} ->
        redirect(conn, to: venue_path(conn, :show, venue.slug))

      {:error, _} ->
        render(conn, "add_photo.html",
          id: venue.entry_id,
          venue_images: venue.venue_images,
          error: true
        )
    end
  end

  def view_admins(conn, %{"slug" => slug}) do
    venue = Venue.get_by(slug: slug)
    venue_owners = get_venue_owners(venue)
    render(conn, "view_owners.html", venue: venue, owners: venue_owners)
  end

  def new_venue_user(conn, %{"v_id" => venue_id}) do
    venue = Repo.get(Venue, venue_id)
    changeset = User.changeset(%User{}, %{})
    render(conn, "add_admin_to_venue.html", venue: venue, changeset: changeset)
  end

  def create_venue_user(conn, %{"v_id" => venue_id, "user" => params}) do
    changeset = User.changeset(%User{}, params)
    venue = Repo.get(Venue, venue_id)

    case changeset.valid? do
      true ->
        # valid email format
        case User.get_by(email_hash: params["email"]) do
          nil ->
            # user does not exist, create them
            params = Map.put(params, "role", "venue_admin")
            {:ok, user} = %User{} |> User.changeset(params) |> User.insert()
            send_email(user, true, venue)

            # associate the user with the venue (add them to venues_users table)
            Repo.insert!(%VenueUser{venue_id: venue.id, user_id: user.id})

            # redirect back to view admins
            conn
            |> put_flash(:info, "New user created. They have been made an admin for this venue")
            |> redirect(to: venue_path(conn, :view_admins, venue.slug))

          user ->
            # user already exists. check if they are already associated with the venue
            is_user_already_this_venues_admin? =
              venue
              |> get_venue_owners()
              |> Enum.map(&(&1.id))
              |> Enum.any?(&(&1 == user.id))

            case is_user_already_this_venues_admin? do
              true ->
                conn
                |> put_flash(:error, "User is already an admin for this venue")
                |> redirect(to: venue_path(conn, :view_admins, venue.slug))

              false ->
                Repo.insert!(%VenueUser{venue_id: venue.id, user_id: user.id})
                send_email(user, false, venue)

                conn
                |> put_flash(:info, "User has been made an admin for this venue")
                |> redirect(to: venue_path(conn, :view_admins, venue.slug))
            end
        end

      false ->
        # invalid email
        render(conn, "add_admin_to_venue.html", venue: venue, changeset: changeset)
    end
  end

  def delete_venue_admin(conn, %{"v_id" => venue_id, "u_id" => user_id}) do
    query = from vu in VenueUser, where: vu.venue_id == ^venue_id and vu.user_id == ^user_id
    venue_user = Repo.one(query)
    venue = Repo.get(Venue, venue_id)

    if venue_user do
      Repo.delete_all(query)

      conn
      |> put_flash(:info, "User removed as owner of this venue")
      |> redirect(to: venue_path(conn, :view_admins, venue.slug))
    else

      conn
      |> put_flash(:info, "User or venue given were incorrect")
      |> redirect(to: venue_path(conn, :view_admins, venue.slug))
    end
  end

  # HELPERS

  defp get_venue_owners(venue) do
    query =
      from u in User,
      join: vu in "venues_users",
      on: u.id == vu.user_id,
      where: vu.venue_id == ^venue.id

    Repo.all(query)
  end

  defp do_update(conn, venue, venue_params) do
    query = fn s, m ->
      sub =
        from(mod in Map.get(m.__schema__(:association, s), :queryable),
          distinct: mod.entry_id,
          order_by: [desc: :updated_at],
          select: mod
        )

      from(m in subquery(sub), where: not m.deleted, select: m)
    end

    with {:ok, venue} <- Venue.update(venue, venue_params),
         {:ok, venue} <-
           Venue.update(
             venue,
             Map.put(
               venue_params,
               :cs_score,
               CsGuide.Resources.CsScore.calculateScore(
                 venue.drinks
                 |> CsGuide.Repo.preload(drink_types: query.(:drink_types, Drink)),
                 venue.num_cocktails
               )
             )
           ) do
      conn
      |> put_flash(:info, "Venue updated successfully.")
      |> redirect(to: venue_path(conn, :show, venue.slug))
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", venue: venue, changeset: changeset)
    end
  end


  defp compareDates(date1, date2) do
    case NaiveDateTime.compare(date1, date2) do
      :gt ->
        true

      _ ->
        false
    end
  end

  def sort_venues_by_date(venues) do
    Enum.sort(venues, &compareDates(&1.updated_at, &2.updated_at))
  end

  def delete(conn, %{"id" => id}) do
    venue = Venue.get(id)
    {:ok, _v} = Venue.delete(venue)

    conn
    |> put_flash(:info, "Venue deleted successfully.")
    |> redirect(to: venue_path(conn, :index))
  end

  defp getVenueCardsByLatLong(lat, long, venue_name) do
    Venue.nearest_venues(lat, long)
    |> Venue.preload([:venue_types, :venue_images])
    |> Enum.filter(fn v ->
      !Enum.find(v.venue_types, fn type ->
        String.downcase(type.name) == "retailer" || String.downcase(type.name) == "wholesaler"
      end)
    end)
    |> Enum.filter(fn v ->
      v.venue_name != venue_name
    end)
  end

  def sortImagesByMostRecent(venue) do
    Map.update(venue, :venue_images, [], fn images ->
      images
      |> Enum.sort(fn img1, img2 ->
        img1.id >= img2.id
      end)
    end)
  end

  defp getPhotoOfPhotoNumber(venue, photo_number) do
    venue.venue_images
    |> Enum.find(false, fn i ->
      i.photo_number == photo_number
    end)
  end

  defp can_current_user_edit_venue?(conn, venue) do
    case conn.assigns.current_user do
      nil ->
        false

      user ->
        case user.role do
          :site_admin ->
            true

          :venue_admin ->
            # this clause checks to see if the current venue being viewed is
            # in the list of venues the users is allowed to edit
            Enum.any?(user.current_users_venues, &(&1 == venue.entry_id))

          _ ->
            false
        end
    end
  end

  defp send_email(user, new_user?, venue) do
    subject = "You have been made a venue admin"
    if new_user? do
      user = User.reset_password_token(user, @ten_days)

      user.email
      |> CsGuide.Email.send_email(subject, new_user_email_msg(user, venue))
      |> @mailer.deliver_now()

    else
      user.email
      |> CsGuide.Email.send_email(subject, existing_user_email_msg(venue))
      |> @mailer.deliver_now()
    end
  end

  defp new_user_email_msg(user, venue) do
    """
    You have been made an admin of the venue #{venue.venue_name}
    Please click the following link to set the password on your account.
    #{Application.get_env(:cs_guide, :site_url)}/password/#{user.password_reset_token}/edit
    """
  end

  defp existing_user_email_msg(venue) do
    """
    You have been made an admin of the venue #{venue.venue_name}
    """
  end
end
