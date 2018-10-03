defmodule CsGuide.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias CsGuide.Repo

  alias CsGuide.Resources.Venue

  @doc """
  Returns the list of venues.

  ## Examples

      iex> list_venues()
      [%Venue{}, ...]

  """
  def list_venues do
    Repo.all(Venue)
  end

  @doc """
  Gets a single venue.

  Raises `Ecto.NoResultsError` if the Venue does not exist.

  ## Examples

      iex> get_venue!(123)
      %Venue{}

      iex> get_venue!(456)
      ** (Ecto.NoResultsError)

  """
  def get_venue!(id), do: Repo.get!(Venue, id)

  @doc """
  Creates a venue.

  ## Examples

      iex> create_venue(%{field: value})
      {:ok, %Venue{}}

      iex> create_venue(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_venue(attrs \\ %{}) do
    %Venue{}
    |> Venue.changeset(attrs)
    |> (fn c ->
          types =
            Enum.map(attrs["venue_types"], fn {type, active} ->
              if active do
                Repo.get_by(CsGuide.Categories.VenueType, type: type)
              end
            end)

          Ecto.Changeset.put_assoc(c, :venue_types, types)
        end).()
    |> (fn c ->
          drinks =
            Enum.map(attrs["drinks"], fn {name, active} ->
              if active do
                Repo.get_by(CsGuide.Resources.Drink, name: name)
              end
            end)

          Ecto.Changeset.put_assoc(c, :drinks, drinks)
        end).()
    |> Repo.insert()
  end

  @doc """
  Updates a venue.

  ## Examples

      iex> update_venue(venue, %{field: new_value})
      {:ok, %Venue{}}

      iex> update_venue(venue, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_venue(%Venue{} = venue, attrs) do
    venue
    |> Venue.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Venue.

  ## Examples

      iex> delete_venue(venue)
      {:ok, %Venue{}}

      iex> delete_venue(venue)
      {:error, %Ecto.Changeset{}}

  """
  def delete_venue(%Venue{} = venue) do
    Repo.delete(venue)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking venue changes.

  ## Examples

      iex> change_venue(venue)
      %Ecto.Changeset{source: %Venue{}}

  """
  def change_venue(%Venue{} = venue) do
    Venue.changeset(venue, %{})
  end

  alias CsGuide.Resources.Drink

  @doc """
  Returns the list of drinks.

  ## Examples

      iex> list_drinks()
      [%Drink{}, ...]

  """
  def list_drinks do
    Repo.all(Drink)
  end

  @doc """
  Gets a single drink.

  Raises `Ecto.NoResultsError` if the Drink does not exist.

  ## Examples

      iex> get_drink!(123)
      %Drink{}

      iex> get_drink!(456)
      ** (Ecto.NoResultsError)

  """
  def get_drink!(id), do: Repo.get!(Drink, id)

  @doc """
  Creates a drink.

  ## Examples

      iex> create_drink(%{field: value})
      {:ok, %Drink{}}

      iex> create_drink(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_drink(attrs \\ %{}) do
    %Drink{}
    |> Drink.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a drink.

  ## Examples

      iex> update_drink(drink, %{field: new_value})
      {:ok, %Drink{}}

      iex> update_drink(drink, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_drink(%Drink{} = drink, attrs) do
    drink
    |> Drink.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Drink.

  ## Examples

      iex> delete_drink(drink)
      {:ok, %Drink{}}

      iex> delete_drink(drink)
      {:error, %Ecto.Changeset{}}

  """
  def delete_drink(%Drink{} = drink) do
    Repo.delete(drink)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking drink changes.

  ## Examples

      iex> change_drink(drink)
      %Ecto.Changeset{source: %Drink{}}

  """
  def change_drink(%Drink{} = drink) do
    Drink.changeset(drink, %{})
  end
end
