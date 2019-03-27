defmodule CsGuide.ChangesetHelpers do
  def update_error_msg(changeset, field_type, error_msg) do
    Map.update!(
      changeset,
      :errors,
      &Enum.map(&1, fn {key, {msg, types}} = error ->
        case types do
          [type: ^field_type, validation: :cast] ->
            {key, {error_msg, types}}

          _ ->
            error
        end
      end)
    )
  end

  def check_existing_slug(changeset, slug, module, field_name, err_msg) do
    existing_slug =
      case module.get_by(slug: slug) do
        nil -> ""
        existing_item -> existing_item.slug
      end

    if slug == existing_slug do
      {_, changeset_with_error} =
        Ecto.Changeset.add_error(changeset, field_name, err_msg,
          type: :string,
          validation: :cast
        )
        |> Ecto.Changeset.apply_action(:insert)

      changeset_with_error
    else
      changeset
    end
  end

end
