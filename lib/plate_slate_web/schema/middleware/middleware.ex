defmodule PlateSlateWeb.Schema.Middleware do
  def apply(middleware, :errors, _field, %{identifier: :mutation}) do
    middleware ++ [__MODULE__.ChangesetErrors]
  end

  def apply(middleware, :get_string, field, %{identifier: :allergy_info} = object) do
    Absinthe.Schema.replace_default(
      middleware,
      {Absinthe.Middleware.MapGet, to_string(field.identifier)},
      field,
      object
    )
  end

  def apply(middleware, :debug, _field, _object) do
    if System.get_env("DEBUG") do
      [{__MODULE__.Debug, :start}] ++ middleware
    else
      middleware
    end
  end

  def apply(middleware, _, _, _), do: middleware
end
