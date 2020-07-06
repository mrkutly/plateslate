defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.{Menu, Repo}

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end

  def create_item(_, %{input: input}, _) do
    with {:ok, menu_item} <- Menu.create_item(input) do
      {:ok, %{menu_item: menu_item}}
    end
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, Repo.all(query)}
  end

  def menu_items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end
end
