defmodule CsGuide.Resources do
  @moduledoc """
  The Resources context.
  """

  import Ecto.Query, warn: false
  alias CsGuide.Repo

  alias CsGuide.Resources.Venue

  def put_many_to_many_assoc(item, attrs, assoc, assoc_module, field) do
    assocs =
      Enum.map(get_assoc_attrs(assoc, attrs), fn a ->
        case a do
          {f, active} ->
            if String.to_existing_atom(active) do
              Repo.one(
                from(a in assoc_module,
                  where: field(a, ^field) == ^f,
                  limit: 1,
                  order_by: [desc: :updated_at],
                  select: a
                )
              )
            else
              nil
            end

          f ->
            f
        end
      end)
      |> Enum.filter(& &1)

    Ecto.Changeset.put_assoc(item, assoc, assocs)
  end

  def put_belongs_to_assoc(item, attrs, assoc, assoc_field, assoc_module, field) do
    assoc = Map.get(attrs, assoc, Map.get(attrs, to_string(assoc), ""))

    loaded_assoc =
      Repo.one(
        from(a in assoc_module,
          where: field(a, ^field) == ^assoc,
          limit: 1,
          order_by: [desc: :updated_at],
          select: a
        )
      )

    case loaded_assoc do
      nil ->
        item

      loaded ->
        Map.put(item, assoc_field, loaded_assoc.id)
    end
  end

  defp get_assoc_attrs(assoc, attrs) do
    assoc_attrs = Map.get(attrs, assoc, Map.get(attrs, to_string(assoc), []))

    case Enumerable.impl_for(assoc_attrs) do
      nil -> []
      _ -> assoc_attrs
    end
  end

  def require_assocs(changeset, assocs) do
    Enum.reduce(assocs, changeset, fn a, c ->
      if length(Map.get(c.changes, a, [])) < 1 do
        Ecto.Changeset.add_error(c, a, "can't be blank", validation: :required)
      else
        c
      end
    end)
  end

  def upload_photo(params, filename) do
    file = File.read!(params["photo"].path)

    Application.get_env(:ex_aws, :bucket)
    |> ExAws.S3.put_object(filename, file)
    |> ExAws.request()
  end
end
