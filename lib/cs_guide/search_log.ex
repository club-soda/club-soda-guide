defmodule CsGuide.SearchLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_log" do
    field(:search, :string)
    timestamps()
  end

  @doc false
  def changeset(search_log, attrs \\ %{}) do
    search_log
    |> cast(attrs, [:search])
  end

end
