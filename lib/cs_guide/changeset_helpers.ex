defmodule CsGuide.ChangesetHelpers do
  def update_error_msg(changeset, type, error_msg) do
    Map.update!(
      changeset,
      :errors,
      &Enum.map(&1, fn {key, {msg, types}} = error ->
        case types do
          [type: type, validation: :cast] ->
            {key, {error_msg, types}}

          _ ->
            error
        end
      end)
    )
  end
end
