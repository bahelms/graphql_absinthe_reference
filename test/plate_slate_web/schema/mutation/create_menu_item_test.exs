defmodule PlateSlateWeb.Schema.Query.CreateMenuItemTest do
  use PlateSlateWeb.ConnCase, async: true
  import Ecto.Query
  alias PlateSlate.{Menu, Repo}

  setup do
    PlateSlate.Seeds.run()

    from(c in Menu.Category, select: c.id, where: c.name == "Sandwiches")
    |> Repo.one!()
    |> to_string()

    :ok
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """
  test "createMenuItem field creates an Item", %{conn: conn} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category" => %{"name" => "Sandwiches"}
    }

    response = post(conn, "/api", query: @query, variables: %{menuItem: menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "errors" => nil,
                 "menuItem" => %{
                   "name" => menu_item["name"],
                   "description" => menu_item["description"],
                   "price" => menu_item["price"]
                 }
               }
             }
           }
  end

  test "creating a menu item with an existing name fails", %{conn: conn} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category" => %{"name" => "Sandwiches"}
    }

    response = post(conn, "/api", query: @query, variables: %{menuItem: menu_item})

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "menuItem" => nil,
                 "errors" => [
                   %{"key" => "name", "message" => "has already been taken"}
                 ]
               }
             }
           }
  end

  @query """
  mutation ($menuItem: MenuItemInput!) {
    createMenuItem(input: $menuItem) {
      menuItem {
        name
        description
        price
      }
    }
  }
  """
  test "createMenuItem creates new category", %{conn: conn} do
    menu_item = %{
      "name" => "French Dip",
      "description" => "Roast beef, caramelized onions, horseradish, ...",
      "price" => "5.75",
      "category" => %{"name" => "Barf"}
    }

    response = post(conn, "/api", query: @query, variables: %{menuItem: menu_item})

    assert Repo.get_by(Menu.Category, name: "Barf")

    assert json_response(response, 200) == %{
             "data" => %{
               "createMenuItem" => %{
                 "menuItem" => %{
                   "name" => menu_item["name"],
                   "description" => menu_item["description"],
                   "price" => menu_item["price"]
                 }
               }
             }
           }
  end
end
