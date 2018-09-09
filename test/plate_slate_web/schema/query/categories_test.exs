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
  test "categories field returns categories", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert json = json_response(response, 200)
    assert length(json["data"]["categories"]) == 3
  end

  @query """
  {
    categories(matching: "and") {
      name
    }
  }
  """
  test "categories field matches against name", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{
      "data" => %{
        "categories" => [%{"name" => "Sandwiches"}]
      }
    } == json_response(response, 200)
  end

  @query """
  {
    categories {
      name
    }
  }
  """
  test "categories order defaults to ascending", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{
      "data" => %{
        "categories" => [
          %{"name" => "Beverages"},
          %{"name" => "Sandwiches"},
          %{"name" => "Sides"}
        ]
      }
    } == json_response(response, 200)
  end

  @query """
  {
    categories(order: DESC) {
      name
    }
  }
  """
  test "categories can be ordered by name descending", %{conn: conn} do
    response = get(conn, "/api", query: @query)
    assert %{
      "data" => %{
        "categories" => [
          %{"name" => "Sides"},
          %{"name" => "Sandwiches"},
          %{"name" => "Beverages"}
        ]
      }
    } == json_response(response, 200)
  end
end
