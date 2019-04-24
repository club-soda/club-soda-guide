defmodule CsGuideWeb.DiscountCodeController do
  use CsGuideWeb, :controller
  alias CsGuide.Resources.{Venue}
  alias CsGuide.DiscountCode

  def index(conn, _params) do
    discount_codes = DiscountCode.all()

    render(conn, "index.html", discount_codes: discount_codes)
  end

  def new(conn, _params) do
    changeset = DiscountCode.changeset(%DiscountCode{}, %{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"discount_code" => discount_code_params}) do
    retailer = discount_code_params["venue_name"]
    retailer_id = Venue.get_by(venue_name: retailer).id
    discount_code_params = Map.put(discount_code_params, "venue_id", retailer_id)

    case DiscountCode.insert(discount_code_params) do
      {:ok, _discount_code} ->
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
end
