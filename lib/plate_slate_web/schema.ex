# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  import Ecto.Query
  alias PlateSlate.Menu
  alias PlateSlateWeb.Resolvers

  query do
    @desc "The list of available items on the menu!"
    field :menu_items, list_of(:menu_item) do
      arg :matching, :string
      # enum values are passed in as all uppercase
      arg :order, type: :sort_order, default_value: :asc
      resolve(&Resolvers.Menu.menu_items/3)
    end
  end

  @desc "List of items on the menu"
  object :menu_item do
    field(:id, :id)

    @desc "Name of item"
    field(:name, :string)

    @desc "Description of item"
    field(:description, :string)

    @desc "Current price of item"
    field(:price, :integer)
  end

  enum :sort_order do
    value :asc
    value :desc
  end
end
