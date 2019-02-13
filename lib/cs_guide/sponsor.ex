defmodule CsGuide.Sponsor do
  use Ecto.Schema
  use Alog
  alias CsGuide.Repo
  import Ecto.Changeset
  import Ecto.Query

  schema "sponsor" do
    field(:name, :string)
    field(:body, :string)
    field(:show, :boolean, default: false)
    field(:entry_id, :string)
    field(:deleted, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(sponsor, attrs \\ %{}) do
    sponsor
    |> cast(attrs, [:name, :body, :show])
    |> validate_required([:name, :body])
  end

  def insert(attrs) do
    %__MODULE__{}
    |> insert_entry_id()
    |> __MODULE__.changeset(attrs)
    |> CsGuide.Repo.insert()
  end

  def getShowingSponsor() do
    sub =
      from(s in __MODULE__,
        distinct: s.entry_id,
        order_by: [desc: :updated_at],
        select: s
      )

    query = from(s in subquery(sub), where: not s.deleted and s.show, select: s)

    query
    |> last(:inserted_at)
    |> Repo.one()
  end
end
