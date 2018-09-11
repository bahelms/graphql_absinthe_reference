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
          "price" => menu_item["price"],
        }
      }
    }
  end
end
