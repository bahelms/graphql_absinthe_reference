defmodule PlateSlateWeb.ItemController do
  use PlateSlateWeb, :controller
  use Absinthe.Phoenix.Controller, schema: PlateSlateWeb.Schema

  @graphql """
  query Index @action(mode: INTERNAL) {
    menu_items @put {
      category
    }
  }
  """
  def index(conn, result) do
    # result is the data returned after the query is executed
    render(conn, :index, items: result.data.menu_items)
  end
end
