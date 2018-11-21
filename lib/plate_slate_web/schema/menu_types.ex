defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  object :menu_queries do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      # enum values are passed in as all uppercase
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.items/3)
    end

    @desc "List of current item categories"
    field :categories, list_of(:category) do
      arg(:matching, :string)
      arg(:order, type: :sort_order, default_value: :asc)
      resolve(&Resolvers.Menu.categories/3)
    end
  end

  @desc "Item available on the menu"
  object :menu_item do
    interfaces([:search_result])
    field(:id, :id)

    @desc "Name of item"
    field(:name, :string)

    @desc "Description of item"
    field(:description, :string)

    @desc "Current price of item"
    field(:price, :decimal)

    @desc "Date added to menu"
    field(:added_on, :date)

    @desc "Information regarding food allergies"
    field(:allergy_info, list_of(:allergy_info))

    @desc "Item category"
    field :category, :category do
      resolve(&Resolvers.Menu.category_for_item/3)
    end

    field :order_history, :order_history do
      arg(:since, :date)
      middleware(Middleware.Authorize, "employee")
      resolve(&Resolvers.Ordering.order_history/3)
    end
  end

  object :order_history do
    field :orders, list_of(:order) do
      resolve(&Resolvers.Ordering.orders/3)
    end

    field :quantity, non_null(:integer) do
      resolve(Resolvers.Ordering.stat(:quantity))
    end

    @desc "Gross Revenue"
    field :gross, non_null(:float) do
      resolve(Resolvers.Ordering.stat(:gross))
    end
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field(:name, :string)

    @desc "Matching a category name"
    # when a filter object is provided, category is required
    field(:category, :string)
    # field(:category, non_null(:string))

    @desc "Matching a tag"
    field(:tag, :string)

    @desc "Priced above a value"
    field(:priced_above, :decimal)

    @desc "Priced below a value"
    field(:priced_below, :decimal)

    @desc "Added to menu before this date"
    field(:added_before, :date)

    @desc "Added to menu after this date"
    field(:added_after, :date)
  end

  object :category do
    interfaces([:search_result])
    field(:name, :string)
    field(:description, :string)

    field :items, list_of(:menu_item) do
      arg(:filter, :menu_item_filter)
      arg(:order, type: :sort_order, default_value: :asc)
      # resolve(&Resolvers.Menu.items_for_category/3)
      # This does the same thing as Resolves.Menu.items_for_category
      resolve(dataloader(Menu, :items))
    end
  end

  interface :search_result do
    field(:name, :string)

    resolve_type(fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end)
  end

  input_object :menu_item_input do
    field(:name, non_null(:string))
    field(:description, :string)
    field(:price, non_null(:decimal))
    field(:category, non_null(:category_input))
  end

  input_object :category_input do
    field(:name, :string)
  end

  object :menu_item_result do
    field(:menu_item, :menu_item)
    field(:errors, list_of(:input_error))
  end

  object :allergy_info do
    field(:allergen, :string)
    field(:severity, :string)
  end
end
