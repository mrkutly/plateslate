defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers
  alias PlateSlate.Menu.{Category, Item}

  object :menu_queries do
    field :menu_items, list_of(:menu_item), description: "The list of available items on the menu" do
      arg(:filter, :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.menu_items/3)
    end

    field :categories, list_of(:category),
      description: "The list of available categories on the menu" do
      arg(:matcher, :string)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.categories/3)
    end
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Added after a date"
    field(:added_after, :date)

    @desc "Added before a date"
    field(:added_before, :date)

    @desc "Matching a category name"
    field(:category, :string)

    @desc "Matching a name"
    field(:name, :string)

    @desc "Priced above a value"
    field(:priced_above, :float)

    @desc "Priced below a value"
    field(:priced_below, :float)

    @desc "Matching a tag"
    field(:tag, :string)
  end

  @desc "Represents an item on the menu"
  object :menu_item do
    interfaces([:search_result])
    field(:id, :id)

    @desc "date the item was added to the menu"
    field(:added_on, :date)

    field(:description, :string)
    field(:name, non_null(:string))
  end

  @desc "Represents a category of items on the menu"
  object :category do
    interfaces([:search_result])
    field(:id, :id)
    field(:name, non_null(:string))
    field(:description, :string)

    field(:items, list_of(:menu_item)) do
      resolve(&Resolvers.Menu.items_for_category/3)
    end
  end

  @desc "Interface a possible search result"
  interface :search_result do
    field(:name, non_null(:string))

    resolve_type(fn
      %Item{}, _ -> :menu_item
      %Category{}, _ -> :category
      _, _ -> nil
    end)
  end
end
