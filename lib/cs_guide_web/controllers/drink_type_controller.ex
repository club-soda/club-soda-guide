defmodule CsGuideWeb.DrinkTypeController do
  use CsGuideWeb, :controller

  alias CsGuide.Categories.DrinkType

  def index(conn, _params) do
    drink_type = DrinkType.all()
    render(conn, "index.html", drink_type: drink_type)
  end

  def new(conn, _params) do
    changeset = DrinkType.changeset(%DrinkType{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"drink_type" => drink_type_params}) do
    case DrinkType.insert(drink_type_params) do
      {:ok, drink_type} ->
        conn
        |> put_flash(:info, "Drink types created successfully.")
        |> redirect(to: drink_type_path(conn, :show, drink_type.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drink_type = DrinkType.get(id)
    render(conn, "show.html", drink_type: drink_type)
  end

  def edit(conn, %{"id" => id}) do
    drink_type = DrinkType.get(id)
    changeset = DrinkType.changeset(drink_type)
    render(conn, "edit.html", drink_type: drink_type, changeset: changeset)
  end

  def update(conn, %{"id" => id, "drink_type" => drink_type_params}) do
    drink_type = DrinkType.get(id)

    case DrinkType.update(drink_type, drink_type_params) do
      {:ok, drink_type} ->
        conn
        |> put_flash(:info, "Drink types updated successfully.")
        |> redirect(to: drink_type_path(conn, :show, drink_type.entry_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", drink_type: drink_type, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    # drink_type = Categories.get_drink_type!(id)
    # {:ok, _drink_type} = Categories.delete_drink_type(drink_type)

    # conn
    # |> put_flash(:info, "Drink types deleted successfully.")
    # |> redirect(to: drink_type_path(conn, :index))
  end
end
