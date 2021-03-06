# ---
# Excerpted from "Craft GraphQL APIs in Elixir with Absinthe",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/wwgraphql for more book information.
# ---
defmodule PlateSlate.Menu do
  @moduledoc """
  The Menu context.
  """

  import Ecto.Query, warn: false
  alias PlateSlate.Repo
  alias PlateSlate.Menu.{Category, Item}

  @doc """
  Dataloader usage examples:
      alias PlateSlate.Menu
      source = Menu.data()
      loader = Dataloader.new() |> Dataloader.add_source(Menu, source)
      loader = (
        loader
        |> Dataloader.load(Menu, Menu.Item, 1)
        |> Dataloader.load(Menu, Menu.Item, 2)
      )
      loader = Dataloader.run(loader)

      # results
      item = Dataloader.get(loader, Menu, Menu.Item, 2)
      items = Dataloader.get_many(loader, Menu, Menu.Item, [1, 2])

      # associations
      loader = (
        loader
        |> Dataloader.load_many(Menu, :category, items)
        |> Dataloader.run()
      )
      categories = Dataloader.get_many(loader, Menu, :category, items)
  """
  def data do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Item, args) do
    items_query(args)
  end

  def query(queryable, _) do
    queryable
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories(args) do
    Enum.reduce(args, Category, fn
      {:order, order}, categories ->
        order_by(categories, {^order, :name})

      {:matching, name}, categories ->
        where(categories, [c], ilike(c.name, ^"%#{name}%"))
    end)
    |> Repo.all()
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{source: %Category{}}

  """
  def change_category(%Category{} = category) do
    Category.changeset(category, %{})
  end

  def find_or_create_category(params) do
    case Repo.get_by(Category, name: params.name) do
      nil ->
        create_category(params)

      category ->
        category
    end
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(args) do
    args
    |> items_query()
    |> Repo.all()
  end

  defp items_query(args) do
    Enum.reduce(args, Item, fn
      {:order, order}, items ->
        order_by(items, {^order, :name})

      {:filter, filter}, items ->
        filter_with(items, filter)
    end)
  end

  @spec filter_with(Ecto.Query.t(), map) :: Ecto.Query.t()
  defp filter_with(items, filter) do
    Enum.reduce(filter, items, fn
      {:name, name}, items ->
        from(item in items, where: ilike(item.name, ^"%#{name}%"))

      {:priced_above, price}, items ->
        from(item in items, where: item.price >= ^price)

      {:priced_below, price}, items ->
        from(item in items, where: item.price <= ^price)

      {:added_before, date}, items ->
        from(item in items, where: item.added_on <= ^date)

      {:added_after, date}, items ->
        from(item in items, where: item.added_on >= ^date)

      {:category, category_name}, items ->
        from(item in items,
          join: c in assoc(item, :category),
          where: ilike(c.name, ^"%#{category_name}%")
        )

      {:tag, tag_name}, items ->
        from(item in items,
          join: t in assoc(item, :tags),
          where: ilike(t.name, ^"%#{tag_name}%")
        )
    end)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  def get_item_by(param) do
    Repo.get_by(Item, param)
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  @search [Item, Category]
  def search(term) do
    pattern = "%#{term}%"
    Enum.flat_map(@search, &search_ecto(&1, pattern))
  end

  defp search_ecto(schema, pattern) do
    schema
    |> where([s], ilike(s.name, ^pattern) or ilike(s.description, ^pattern))
    |> Repo.all()
  end

  def categories_by_id(_, ids) do
    Category
    |> where([c], c.id in ^Enum.uniq(ids))
    |> Repo.all()
    |> Map.new(fn category -> {category.id, category} end)
  end
end
