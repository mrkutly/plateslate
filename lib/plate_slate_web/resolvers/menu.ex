defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.{Menu, Repo}
  import Ecto.Changeset, only: [traverse_errors: 2]

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end

  def create_item(_, %{input: input}, _) do
    case Menu.create_item(input) do
      {:error, changeset} ->
        {:ok, %{errors: transform_errors(changeset)}}

      {:ok, menu_item} ->
        {:ok, %{menu_item: menu_item}}
    end
  end

  defp transform_errors(changeset) do
    changeset
    |> traverse_errors(&format_error/1)
    |> Enum.map(fn
      {key, value} ->
        %{key: key, message: value}
    end)
  end

  @spec format_error(Ecto.Changeset.error()) :: String.t()
  defp format_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
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
