defmodule CsGuideWeb.DrinkStyleController do
  use CsGuideWeb, :controller

  alias CsGuide.Categories
  alias CsGuide.Categories.DrinkStyle

  def index(conn, _params) do
    drink_styles = DrinkStyle.all()
    render(conn, "index.html", drink_styles: drink_styles)
  end

  def new(conn, _params) do
    changeset = DrinkStyle.changeset(%DrinkStyle{}, %{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"drink_style" => drink_style_params}) do
    case DrinkStyle.insert(drink_style_params) do
      {:ok, drink_style} ->
        conn
        |> put_flash(:info, "Drink style created successfully.")
        |> redirect(to: drink_style_path(conn, :show, drink_style))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    drink_style = DrinkStyle.get(id)
    render(conn, "show.html", drink_style: drink_style)
  end

  def edit(conn, %{"id" => id}) do
    drink_style = DrinkStyle.get(id)
    changeset = DrinkStyle.changeset(drink_style, %{})
    render(conn, "edit.html", drink_style: drink_style, changeset: changeset)
  end

  def update(conn, %{"id" => id, "drink_style" => drink_style_params}) do
    drink_style = Categories.get_drink_style!(id)

    case Drink.update(drink_style, drink_style_params) do
      {:ok, drink_style} ->
        conn
        |> put_flash(:info, "Drink style updated successfully.")
        |> redirect(to: drink_style_path(conn, :show, drink_style))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", drink_style: drink_style, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    drink_style = DrinkStyle.get(id)
    {:ok, _drink_style} = DrinkStyle.delete(drink_style)

    conn
    |> put_flash(:info, "Drink style deleted successfully.")
    |> redirect(to: drink_style_path(conn, :index))
  end
end
