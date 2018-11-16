defmodule PlateSlateWeb.Schema.Middleware.Debug do
  @behaviour Absinthe.Middleware

  def call(resolution, :start) do
    path = resolution |> Absinthe.Resolution.path() |> Enum.join(".")

    IO.puts("""
    ========================
    starting: #{path}
    with source: #{inspect(resolution.source)}\
    """)

    middleware = resolution.middleware ++ [{__MODULE__, {:finish, path}}]
    %{resolution | middleware: middleware}
  end

  def call(resolution, {:finish, path}) do
    IO.puts("""
    completed: #{path}
    value: #{inspect(resolution.value)}
    ========================\
    """)

    resolution
  end
end
