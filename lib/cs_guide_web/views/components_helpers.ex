defmodule CsGuideWeb.ComponentsHelpers do
  alias CsGuideWeb.ComponentsView
  use Phoenix.HTML

  def component(template, assigns \\ []) do
    ComponentsView.render("#{template}.html", assigns)
  end

  def primary_btn(title, url) do
    content_tag(:a, title, href: url, class: "btn-primary no-underline")
  end

  def secondary_btn(title, url) do
    content_tag(:a, title, href: url, class: "bg-cs-black br2 ph4 pv2 white no-underline")
  end
end
