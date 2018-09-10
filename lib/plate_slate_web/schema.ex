defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema

  import_types(__MODULE__.MenuTypes)

  query do
    import_fields :menu_queries

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&PlateSlateWeb.Resolvers.Menu.search/3)
    end
  end

  enum :sort_order do
    value(:asc)
    value(:desc)
  end

  scalar :date do
    parse(fn input ->
      with %Absinthe.Blueprint.Input.String{value: value} <- input,
           {:ok, date} <- Date.from_iso8601(value) do
        {:ok, date}
      else
        _ -> :error
      end
    end)

    serialize(fn date ->
      Date.to_iso8601(date)
    end)
  end
end
