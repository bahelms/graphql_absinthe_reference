defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems {
      name
      price
    }
  }
  """
  test "menuItems field returns menu items", %{conn: conn} do
    conn = get(conn, "/api", query: @query)
    assert json = json_response(conn, 200)
    assert length(json["data"]["menuItems"]) == 14
    [item | _] = json["data"]["menuItems"]
    assert item == %{"name" => "Bánh mì", "price" => "4.5"}
  end

  @query """
  {
    menuItems(filter: {name: "reu"}) {
      name
    }
  }
  """
  test "menuItems field returns menu items filtered by name", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Reuben"}
        ]
      }
    }
  end

  @query """
  query ($term: String) {
    menuItems(filter: {name: $term}) {
      name
    }
  }
  """
  test "menuItems field filters by name when using a variable", %{conn: conn} do
    response = get(conn, "/api", query: @query, variables: %{"term" => "reu"})
    assert json_response(response, 200) == %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Reuben"}
        ]
      }
    }
  end

  @query """
  {
    menuItems(filter: {name: 123}) {
      name
    }
  }
  """
  test "menuItems field returns errors with a bad value", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{"errors" => [%{"message" => message}]} = json_response(response, 400)
    assert message =~ "Argument \"filter\" has invalid value {name: 123}."
  end

  @query """
  {
    menuItems(order: DESC) {
      name
    }
  }
  """
  test "menuItems field returns items descending using literals", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
    } = json_response(response, 200)
  end

  @query """
  query ($order: SortOrder!) {
    menuItems(order: $order) {
      name
    }
  }
  """
  test "menuItems field returns items descending using variables", %{conn: conn} do
    response = get(conn, "/api", query: @query, variables: %{order: "DESC"})
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
    } = json_response(response, 200)
  end

  @query """
  {
    menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
      name
    }
  }
  """
  test "menuItems field returns menuItems, filtering by literals", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } = json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  test "menuItems field returns menuItems, filtering by variable", %{conn: conn} do
    filters = %{filter: %{category: "Sandwiches", tag: "Vegetarian"}}
    response = get(conn, "/api", query: @query, variables: filters)
    assert %{
      "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
    } = json_response(response, 200)
  end
end
