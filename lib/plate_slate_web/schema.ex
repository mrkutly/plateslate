defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias Absinthe.Blueprint.Input
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware
  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.OrderingTypes)
  import_types(__MODULE__.AccountTypes)

  def middleware(middleware, field, %{identifier: :allergy_info} = object) do
    new_middleware = {Absinthe.Middleware.MapGet, to_string(field.identifier)}

    middleware
    |> Absinthe.Schema.replace_default(new_middleware, field, object)
  end

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  query do
    import_fields(:menu_queries)

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  mutation do
    import_fields(:account_mutations)
    import_fields(:menu_mutations)
    import_fields(:order_mutations)
  end

  subscription do
    import_fields(:order_subscriptions)
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field(:key, non_null(:string))
    field(:message, non_null(:string))
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

  scalar :decimal do
    parse(fn
      %{value: value}, _ ->
        Decimal.parse(value)

      _, _ ->
        :error
    end)

    serialize(&to_string/1)
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end
end
