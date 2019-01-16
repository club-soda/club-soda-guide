defmodule CsGuideWeb.DiscountCodeController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.{Venue}
  alias CsGuide.DiscountCode
  import Ecto.Query

  def index(conn, _params) do
    wb_dc = get_discount_code("WiseBartender")
    dd_dc = get_discount_code("DryDrinker")

    render(conn, "index.html", discount_codes: [wb_dc, dd_dc])
  end

  def new(conn, _params) do
    changeset = DiscountCode.changeset(%DiscountCode{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_code" => discount_code_params}) do
    retailer = discount_code_params["venue_name"] |> Map.keys() |> Enum.at(0)
    retailer_id = Venue.get_by(venue_name: retailer).id
    discount_code_params = Map.put(discount_code_params, "venue_id", retailer_id)

    case DiscountCode.insert(discount_code_params) do
      {:ok, discount_code} ->
        conn
        |> put_flash(:info, "Discount code created successfully.")
        |> redirect(to: discount_code_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    discount_code = DiscountCode.get(id)
    render(conn, "show.html", discount_code: discount_code)
  end

  def edit(conn, %{"id" => id}) do
    discount_code = DiscountCode.get(id)
    changeset = DiscountCode.changeset(discount_code)
    render(conn, "edit.html", discount_code: discount_code, changeset: changeset)
  end

  def update(conn, %{"id" => id, "discount_code" => discount_code_params}) do
    discount_code = DiscountCode.get(id)
    changeset = DiscountCode.changeset(discount_code, discount_code_params)

    case DiscountCode.update(changeset) do
      {:ok, discount_code} ->
        conn
        |> put_flash(:info, "Discount code updated successfully.")
        |> redirect(to: discount_code_path(conn, :show, discount_code.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", discount_code: discount_code, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    discount_code = DiscountCode.get(id)
    {:ok, _discount_code} = DiscountCode.delete(discount_code)

    conn
    |> put_flash(:info, "Discount code deleted successfully.")
    |> redirect(to: discount_code_path(conn, :index))
  end

  defp make_query(retailer_id) do
    from(dc in DiscountCode,
      limit: 1,
      select: dc,
      where: dc.venue_id == ^retailer_id,
      order_by: [desc: dc.inserted_at]
    )
  end

  defp get_discount_code(retailer_name) do
    case Venue.get_by(venue_name: retailer_name) do
      nil ->
        nil

      retailer ->
        retailer.id
        |> make_query()
        |> CsGuide.Repo.one()
    end
  end
end
