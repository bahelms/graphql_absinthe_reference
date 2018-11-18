defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end

  def items_for_category(category, _, _) do
    query = Ecto.assoc(category, :items)
    {:ok, PlateSlate.Repo.all(query)}
  end

  def category_for_item(item, _, _) do
    batch({PlateSlate.Menu, :categories_by_id}, item.category_id, fn
      categories ->
        {:ok, Map.get(categories, item.category_id)}
    end)
    |> IO.inspect()
  end

  def search(_, %{matching: term}, _) do
    {:ok, Menu.search(term)}
  end

  def create_item(_, %{input: params}, _) do
    category = Menu.find_or_create_category(params.category)
    params = Map.put(params, :category, category)

    with {:ok, item} <- Menu.create_item(params) do
      {:ok, %{menu_item: item}}
    end
  end

  def update_item(_, %{input: params}, _) do
    with %Menu.Item{} = item <- Menu.get_item_by(name: params.name),
         {:ok, menu_item} <- Menu.update_item(item, params) do
      {:ok, %{menu_item: menu_item}}
    else
      nil ->
        message = "No Item found with name #{params.name}"
        {:ok, %{errors: %{key: "name", message: message}}}
    end
  end
end
