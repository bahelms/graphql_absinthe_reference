defmodule PlateSlateWeb.Schema.Query.SearchTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  query Search($term: String!) {
    search(matching: $term) {
      name
      __typename
    }
  }
  """
  test "search returns list of menu items and categories", %{conn: conn} do
    response = get(conn, "/api", query: @query, variables: %{term: "e"})
    assert %{"data" => %{"search" => results}} = json_response(response, 200)
    assert length(results) > 0
    assert Enum.find(results, &(&1["__typename"] == "Category"))
    assert Enum.find(results, &(&1["__typename"] == "MenuItem"))
  end
end
