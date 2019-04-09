defmodule CsGuide.Resources.Venue do
  use Ecto.Schema
  use Alog
  import Ecto.Changeset
  import Ecto.Query

  alias CsGuide.Repo
  alias CsGuide.{Resources, PostcodeLatLong}

  schema "venues" do
    field(:venue_name, :string)
    field(:parent_company, :string)
    field(:description, Fields.DescriptionPlaintextUnlimited)
    field(:address, Fields.Address)
    field(:city, Fields.Address)
    field(:postcode, Fields.Postcode)
    field(:website, Fields.Url)
    field(:phone_number, Fields.PhoneNumber)
    field(:twitter, Fields.Url)
    field(:facebook, Fields.Url)
    field(:instagram, Fields.Url)
    field(:cs_score, :float, default: 0.0)
    field(:favourite, :boolean, default: false)
    field(:num_cocktails, :integer)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)
    field(:lat, :float)
    field(:long, :float)
    field(:distance, :float, virtual: true)
    field(:slug, :string)

    many_to_many(
      :venue_types,
      CsGuide.Categories.VenueType,
      join_through: "venues_venue_types",
      join_keys: [venue_id: :id, venue_type_id: :id],
      on_replace: :delete
    )

    many_to_many(
      :drinks,
      CsGuide.Resources.Drink,
      join_through: "venues_drinks",
      join_keys: [venue_id: :id, drink_id: :id],
      on_replace: :delete
    )

    many_to_many(
      :users,
      CsGuide.Accounts.User,
      join_through: "venues_users",
      join_keys: [venue_id: :id, user_id: :id],
      on_replace: :delete
    )

    has_many(:venue_images, CsGuide.Images.VenueImage)
    has_many(:discount_codes, CsGuide.DiscountCode)

    timestamps()
  end

  @doc false
  def changeset(venue, attrs \\ %{}) do
    venue
    |> cast(attrs, [
      :venue_name,
      :parent_company,
      :postcode,
      :phone_number,
      :cs_score,
      :description,
      :num_cocktails,
      :website,
      :address,
      :city,
      :twitter,
      :instagram,
      :facebook,
      :favourite,
      :lat,
      :long,
      :slug
    ])
    |> cast_assoc(:users)
    |> validate_required([:venue_name, :parent_company, :postcode, :venue_types, :slug])
  end

  def retailer_changeset(venue, attrs \\ %{}) do
    venue
    |> cast(attrs, [
      :venue_name,
      :postcode,
      :phone_number,
      :cs_score,
      :description,
      :num_cocktails,
      :website,
      :address,
      :city,
      :twitter,
      :instagram,
      :facebook,
      :favourite
    ])
    |> validate_required([:venue_name, :website, :venue_types])
  end

  def insert(changeset, attrs) do
    changeset
    |> insert_entry_id()
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> Resources.require_assocs([:venue_types])
    |> Repo.insert()
  end

  def insert(attrs) do
    %__MODULE__{}
    |> __MODULE__.changeset(attrs)
    |> insert(attrs)
  end

  def retailer_insert(attrs) do
    %__MODULE__{}
    |> __MODULE__.retailer_changeset(attrs)
    |> insert(attrs)
  end

  def update(%__MODULE__{} = item, attrs) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> Repo.insert()
  end

  def update(%__MODULE__{} = item, attrs, postcode) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> validate_postcode(postcode)
    |> Repo.insert()
  end

  def get_venue_card(%__MODULE__{} = venue) do
    %{
      id: venue.entry_id,
      slug: venue.slug,
      name: venue.venue_name,
      types: Enum.map(venue.venue_types, fn v -> v.name end),
      city: venue.city || "",
      postcode: venue.postcode,
      cs_score: venue.cs_score,
      image:
        if img = List.first(venue.venue_images) do
          "https://s3-eu-west-1.amazonaws.com/#{Application.get_env(:ex_aws, :bucket)}/#{
            img.entry_id
          }"
        else
          ""
        end
    }
  end

  def retailer_update(%__MODULE__{} = item, attrs) do
    item
    |> __MODULE__.preload(__MODULE__.__schema__(:associations))
    |> Map.put(:id, nil)
    |> Map.put(:updated_at, nil)
    |> __MODULE__.retailer_changeset(attrs)
    |> Resources.put_many_to_many_assoc(attrs, :venue_types, CsGuide.Categories.VenueType, :name)
    |> Resources.put_many_to_many_assoc(attrs, :drinks, CsGuide.Resources.Drink, :entry_id)
    |> Repo.insert()
  end

  def create_slug(name, postcode) do
    Enum.join([name, "-", postcode])
    |> change_spaces_to_dashes()
    |> String.replace(~r/(,|')/, "")
    |> String.replace(~r/(-{3})/, "-")
    |> String.replace(~r/(&|\+)/, "and")
    |> String.downcase()
  end

  defp change_spaces_to_dashes(str) do
    str
    |> String.split(" ")
    |> Enum.join("-")
  end

  def nearest_venues(lat, long, distance \\ 5_000)

  def nearest_venues(lat, long, distance) when distance < 30_000 do
    case venues_within_distance(distance, lat, long) do
      [] -> nearest_venues(lat, long, distance + 5_000)
      venues -> venues
    end
  end

  def nearest_venues(_, _, _), do: []

  defp venues_within_distance(distance, lat, long) do
    __MODULE__
    |> where(
      [venue],
      fragment(
        "? @> ?",
        fragment(
          "earth_box(?, ?)",
          fragment("ll_to_earth(?, ?)", ^lat, ^long),
          ^distance
        ),
        fragment("ll_to_earth(?,?)", venue.lat, venue.long)
      )
    )
    # filters veunes that are within the given distance
    |> select([venue], %{
      venue
      | distance:
          fragment(
            "? as distance",
            fragment(
              "? <@> ?",
              fragment("point(?, ?)", ^long, ^lat),
              fragment("point(?, ?)", venue.long, venue.lat)
            )
          )
    })
    # selects all venues 'where' tells it to and adds the :distance key to
    # each (:distance is a virtual field that needs to be added to each venue
    # as the lat, long and distance variables passed in can all change)
    |> order_by([v], desc: v.updated_at)
    |> distinct([v], asc: fragment("distance"), asc: :entry_id)
    # filters the results to make sure it returns only venues with a unique
    # combination of distance and entry_id. The reason for the combination is to
    # account for cases where distances could be the same to different venues.
    |> CsGuide.Repo.all()
    |> Enum.filter(&(&1.deleted == false))
  end

  def validate_postcode(%{valid?: true} = changeset, postcode) do
    case PostcodeLatLong.check_or_cache(postcode) do
      {:error, _} ->
        {_, changeset} =
          changeset
          |> add_error(:postcode, "invalid postcode")
          |> apply_action(:insert)

        changeset

      {:ok, {lat, long}} ->
        {lat, _} = Float.parse(lat)
        {long, _} = Float.parse(long)

        change(changeset, %{lat: lat, long: long})
    end
  end

  def validate_postcode(changeset, _postcode), do: changeset
end
