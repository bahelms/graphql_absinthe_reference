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
    assert item == %{"name" => "Reuben", "price" => "4.5"}
  end

  @query """
  {
    menuItems(matching: "reu") {
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
    menuItems(matching: $term) {
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
    menuItems(matching: 123) {
      name
    }
  }
  """
  test "menuItems field returns errors with a bad value", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{"errors" => [%{"message" => message}]} = json_response(response, 400)
    assert message == "Argument \"matching\" has invalid value 123."
  end
end
