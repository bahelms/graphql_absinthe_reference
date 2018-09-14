defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.OrderingTypes)

  def middleware(middleware, _field, %{identifier: :mutation}) do
    middleware ++ [Middleware.ChangesetErrors]
  end

  def middleware(middleware, _field, _object) do
    # Runs for all fields of every object loaded from schema
    # Objects are cached, so it doesn't run on every query
    middleware
  end

  query do
    import_fields(:menu_queries)

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      resolve(&Resolvers.Menu.search/3)
    end
  end

  mutation do
    # second arg is return type
    field :create_menu_item, :menu_item_result do
      # order matters for field macros
      arg(:input, non_null(:menu_item_input))
      resolve(&Resolvers.Menu.create_item/3)
    end

    field :update_menu_item, :menu_item_result do
      arg(:input, non_null(:menu_item_input))
      resolve(&Resolvers.Menu.update_item/3)
    end

    field :place_order, :order_result do
      arg(:input, non_null(:place_order_input))
      resolve(&Resolvers.Ordering.place_order/3)
    end

    field :ready_order, :order_result do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.ready_order/3)
    end

    field :complete_order, :order_result do
      arg(:id, non_null(:id))
      resolve(&Resolvers.Ordering.complete_order/3)
    end
  end

  subscription do
    field :new_order, :order do
      config(fn _args, _info ->
        {:ok, topic: "*"}
      end)

      trigger(:place_order,
        topic: fn
          %{order: _} -> ["*"]
          _ -> []
        end
      )

      resolve(fn %{order: order}, _, _ -> {:ok, order} end)
    end

    field :update_order, :order do
      arg(:id, non_null(:id))

      config(fn args, _info ->
        {:ok, topic: args.id}
      end)

      # first arg: mutation name or list of names
      # second arg: fn receives output of mutation and returns list of topics
      trigger([:ready_order, :complete_order],
        topic: fn
          %{order: order} -> [order.id]
          _ -> []
        end
      )

      resolve(fn %{order: order}, _, _ -> {:ok, order} end)
    end
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field(:key, non_null(:string))
    field(:message, non_null(:string))
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

  scalar :decimal do
    parse(fn
      %{value: value}, _ ->
        Decimal.parse(value)

      _, _ ->
        :error
    end)

    serialize(&to_string/1)
  end
end
