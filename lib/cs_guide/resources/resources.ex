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

  def put_many_to_many_assoc(item, attrs, assoc, assoc_module, field) do
    assocs =
      Enum.map(Map.get(attrs, to_string(assoc)), fn {f, active} ->
        if String.to_existing_atom(active) do
          Repo.one(
            from(a in assoc_module,
              where: field(a, ^field) == ^f,
              limit: 1,
              order_by: [desc: :inserted_at],
              select: a
            )
          )
        else
          nil
        end
      end)
      |> Enum.filter(& &1)

    Ecto.Changeset.put_assoc(item, assoc, assocs)
  end

  def put_belongs_to_assoc(item, attrs, assoc, assoc_field, assoc_module, field) do
    {assoc, _} =
      Enum.find(Map.get(attrs, to_string(assoc)), fn {_, active} ->
        String.to_existing_atom(active)
      end)

    loaded_assoc =
      Repo.one(
        from(a in assoc_module,
          where: field(a, ^field) == ^assoc,
          limit: 1,
          order_by: [desc: :inserted_at],
          select: a
        )
      )

    Map.put(item, assoc_field, loaded_assoc.id)
  end
end
