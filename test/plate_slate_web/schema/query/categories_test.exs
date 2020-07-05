defmodule PlateSlateWeb.Schema.Query.CategoriesTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    categories {
      name
    }
  }
  """
  test "categories field returns all categories" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) == %{
             "data" => %{
               "categories" => [
                 %{"name" => "Beverages"},
                 %{"name" => "Sandwiches"},
                 %{"name" => "Sides"}
               ]
             }
           }
  end

  @query """
  query ($matcher: String!) {
    categories(matcher: $matcher) {
      name
    }
  }
  """
  @variables %{matcher: "bev"}
  test "categories field filters by a name matcher" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert json_response(conn, 200) == %{
             "data" => %{
               "categories" => [
                 %{"name" => "Beverages"}
               ]
             }
           }
  end

  @query """
  query ($order: SortOrder!) {
    categories(order: $order) {
      name
    }
  }
  """
  @variables %{order: "DESC"}
  test "categories field sorts by an order argument" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query, variables: @variables)

    assert json_response(conn, 200) == %{
             "data" => %{
               "categories" => [
                 %{"name" => "Sides"},
                 %{"name" => "Sandwiches"},
                 %{"name" => "Beverages"}
               ]
             }
           }
  end
end
