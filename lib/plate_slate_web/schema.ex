defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias Absinthe.Blueprint.Input
  alias PlateSlateWeb.Resolvers
  import_types(__MODULE__.MenuTypes)

  query do
    import_fields(:menu_queries)

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  scalar :date do
    parse(fn input ->
      with %Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end

  scalar :email do
    parse(fn input ->
      with %Input.String{value: value} <- input,
           {true, email} <- {Regex.match?(~r(^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$), value), value},
           [username, domain] <- String.split(email, "@") do
        {:ok, {username, domain}}
      else
        _ -> :error
      end
    end)

    serialize(fn {username, domain} ->
      username <> "@" <> domain
    end)
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end
end
