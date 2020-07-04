defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias Absinthe.Blueprint.Input
  alias PlateSlate.{Menu, Repo}
  alias PlateSlateWeb.Resolvers

  query do
    field :menu_items, list_of(:menu_item), description: "The list of available items on the menu" do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end

    field :categories, list_of(:category), description: "The list of available categories on the menu" do
      arg :matcher, :string
      arg :order, type: :sort_order, default_value: :asc
      resolve &Resolvers.Menu.categories/3
    end
  end

  @desc "Represents an item on the menu"
  object :menu_item do
    field :id, :id

    @desc "date the item was added to the menu"
    field :added_on, :date

    @desc "description of the item"
    field :description, :string

    @desc "name of the item"
    field :name, :string
  end

  @desc "Represents a category of items on the menu"
  object :category do
    field :id, :id
    field :name, non_null(:string)
    field :description, :string
    field :items, list_of(:menu_item)
  end

  enum :sort_order do
    value :asc
    value :desc
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Added after a date"
    field :added_after, :date

    @desc "Added before a date"
    field :added_before, :date

    @desc "Matching a category name"
    field :category, :string

    @desc "Matching a name"
    field :name, :string

    @desc "Priced above a value"
    field :priced_above, :float

    @desc "Priced below a value"
    field :priced_below, :float

    @desc "Matching a tag"
    field :tag, :string
  end

  scalar :date do
    parse fn input ->
      with %Input.String{value: value} <- input,
      {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end

    serialize fn date ->
      Date.to_iso8601(date)
    end
  end

  scalar :email do
    parse fn input ->
      with %Input.String{value: value} <- input,
      {true, email} <- {Regex.match?(~r(^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$), value), value},
      [username, domain] <- String.split(email, "@") do
        {:ok, {username, domain}}
      else
        _ -> :error
      end
    end

    serialize fn {username, domain} ->
      username <> "@" <> domain
    end
  end
end
