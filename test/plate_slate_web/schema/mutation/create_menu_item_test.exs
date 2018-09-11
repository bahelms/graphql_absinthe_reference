defmodule PlateSlateWeb.Schema.Query.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true
  import Ecto.Query
  alias PlateSlate.{Menu, Repo}

  setup do
    PlateSlate.Seeds.run()

    category_id =
      from(c in Menu.Category, select: c.id, where: c.name == "Sandwiches")
      |> Repo.one!()
      |> to_string()

    {:ok, category_id: category_id}
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      name
      description
      price
    }
  }
  """
  test "createMenuItem field creates an Item", %{conn: conn, category_id: cat_id} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => cat_id
    }

    response = post(conn, "/api", query: @query, variables: %{menuItem: menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "name" => menu_item["name"],
                 "description" => menu_item["description"],
                 "price" => menu_item["price"]
               }
             }
           }
  end

  test "creating a menu item with an existing name fails", %{conn: conn, category_id: cat_id} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "categoryId" => cat_id
    }

    response = post(conn, "/api", query: @query, variables: %{menuItem: menu_item})

    assert json_response(response, 200) == %{
      "data" => %{"createMenuItem" => nil},
      "errors" => [
        %{
          "locations" => [%{"column" => 0, "line" => 2}],
          "message" => "Could not create menu item",
          "details" => %{"name" => ["has already been taken"]},
          "path" => ["createMenuItem"],
        }
      ]
    }
  end
end
