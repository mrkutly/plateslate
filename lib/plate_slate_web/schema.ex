defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlate.{Menu, Repo}

  query do
    field :menu_items, list_of(:menu_item), description: "The list of available items on the menu" do
      resolve fn _, _, _ ->
        {:ok, Repo.all(Menu.Item)}
      end
    end
  end

  @desc "represents an item on the menu"
  object :menu_item do
    field :id, :id

    @desc "name of the item"
    field :name, :string

    @desc "description of the item"
    field :description, :string
  end
end
