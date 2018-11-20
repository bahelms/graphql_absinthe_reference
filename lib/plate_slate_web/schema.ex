defmodule PlateSlateWeb.Schema do
  use Absinthe.Schema
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  import_types(__MODULE__.MenuTypes)
  import_types(__MODULE__.OrderingTypes)
  import_types(__MODULE__.AccountsTypes)
  # provides directives
  import_types(Absinthe.Phoenix.Types)

  def middleware(middleware, field, object) do
    # Runs for all fields of every object loaded from schema
    # Objects are cached, so it doesn't run on every query
    middleware
    |> Middleware.apply(:errors, field, object)
    |> Middleware.apply(:get_string, field, object)
    |> Middleware.apply(:debug, field, object)
  end

  def dataloader do
    Dataloader.new()
    |> Dataloader.add_source(PlateSlate.Menu, PlateSlate.Menu.data())
  end

  @doc """
  Runs after the PlateSlateWeb.Context plug
  """
  def context(ctx) do
    Map.put(ctx, :loader, dataloader())
  end

  @doc """
  Add Dataloader to plugins list. Defaults are Async and Batch.
  """
  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  query do
    import_fields(:menu_queries)

    field :search, list_of(:search_result) do
      arg(:matching, non_null(:string))
      # Resolvers take 3 args: (field_parent, field_args, resolution_struct)
      resolve(&Resolvers.Menu.search/3)
    end

    field :me, :user do
      resolve(&Resolvers.Accounts.me/3)
    end
  end

  mutation do
    # second arg is return type
    field :create_menu_item, :menu_item_result do
      # order matters for field macros
      arg(:input, non_null(:menu_item_input))
      middleware(Middleware.Authorize, "employee")
      resolve(&Resolvers.Menu.create_item/3)
    end

    field :update_menu_item, :menu_item_result do
      arg(:input, non_null(:menu_item_input))
      resolve(&Resolvers.Menu.update_item/3)
    end

    field :place_order, :order_result do
      arg(:input, non_null(:place_order_input))
      middleware(Middleware.Authorize, :any)
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

    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))
      arg(:role, non_null(:role))
      resolve(&Resolvers.Accounts.login/3)

      # Persists between requests for sockets
      middleware(fn res, _ ->
        with %{value: %{user: user}} <- res do
          %{res | context: Map.put(res.context, :current_user, user)}
        end
      end)
    end
  end

  subscription do
    field :new_order, :order do
      config(fn _args, %{context: context} ->
        case context.current_user do
          %{role: "customer", id: id} ->
            {:ok, topic: id}

          %{role: "employee"} ->
            {:ok, topic: "*"}

          _ ->
            {:error, "unauthorized"}
        end
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
