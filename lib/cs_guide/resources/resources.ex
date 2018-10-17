defmodule CsGuide.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias CsGuide.Repo

  alias CsGuide.Resources.Venue

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
              if String.to_existing_atom(active) do
                Repo.get_by(CsGuide.Categories.VenueType, type: type)
              else
                nil
              end
            end)
            |> Enum.filter(& &1)

          Ecto.Changeset.put_assoc(c, :venue_types, types)
        end).()
    |> (fn c ->
          drinks =
            Enum.map(attrs["drinks"], fn {name, active} ->
              if String.to_existing_atom(active) do
                Repo.get_by(CsGuide.Resources.Drink, name: name)
              else
                nil
              end
            end)
            |> Enum.filter(& &1)

          Ecto.Changeset.put_assoc(c, :drinks, drinks)
        end).()
    |> Venue.insert()
  end
end
