defmodule CsGuide.ChangesetHelpers do
  def update_error_msg(changeset, field_type, error_msg) do
    Map.update!(
      changeset,
      :errors,
      &Enum.map(&1, fn {key, {_msg, types}} = error ->
        case types do
          [type: ^field_type, validation: :cast] ->
            {key, {error_msg, types}}

          _ ->
            error
        end
      end)
    )
  end

  def check_existing_slug(changeset, module, field_name, err_msg) do
    with(
      true <- Map.has_key?(changeset.changes, :slug),
      slug <- changeset.changes.slug,
      existing_item when not is_nil(existing_item) <- module.get_by(slug: slug),
      true <- slug == existing_item.slug
    ) do
      {_, changeset_with_error} =
        Ecto.Changeset.add_error(changeset, field_name, err_msg,
          type: :string,
          validation: :cast
        )
        |> Ecto.Changeset.apply_action(:insert)

      changeset_with_error
    else
      _ ->
        changeset
    end
  end
end
