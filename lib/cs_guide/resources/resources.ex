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
end
