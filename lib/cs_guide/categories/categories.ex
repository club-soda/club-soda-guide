defmodule CsGuide.Categories do
  @moduledoc """
  The Categories context.
  """

  import Ecto.Query, warn: false
  alias CsGuide.Repo

  alias CsGuide.Categories.VenueType

  @doc """
  Returns the list of venue_type.

  ## Examples

      iex> list_venue_type()
      [%VenueType{}, ...]

  """
  def list_venue_type do
    Repo.all(VenueType)
  end

  @doc """
  Gets a single venue_type.

  Raises `Ecto.NoResultsError` if the Venue types does not exist.

  ## Examples

      iex> get_venue_type!(123)
      %VenueType{}

      iex> get_venue_type!(456)
      ** (Ecto.NoResultsError)

  """
  def get_venue_type!(id), do: Repo.get!(VenueType, id)

  @doc """
  Creates a venue_type.

  ## Examples

      iex> create_venue_type(%{field: value})
      {:ok, %VenueType{}}

      iex> create_venue_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_venue_type(attrs \\ %{}) do
    %VenueType{}
    |> VenueType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a venue_type.

  ## Examples

      iex> update_venue_type(venue_type, %{field: new_value})
      {:ok, %VenueType{}}

      iex> update_venue_type(venue_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_venue_type(%VenueType{} = venue_type, attrs) do
    venue_type
    |> VenueType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a VenueType.

  ## Examples

      iex> delete_venue_type(venue_type)
      {:ok, %VenueType{}}

      iex> delete_venue_type(venue_type)
      {:error, %Ecto.Changeset{}}

  """
  def delete_venue_type(%VenueType{} = venue_type) do
    Repo.delete(venue_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking venue_type changes.

  ## Examples

      iex> change_venue_type(venue_type)
      %Ecto.Changeset{source: %VenueType{}}

  """
  def change_venue_type(%VenueType{} = venue_type) do
    VenueType.changeset(venue_type, %{})
  end
end
