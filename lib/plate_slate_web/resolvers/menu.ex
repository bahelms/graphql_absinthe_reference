defmodule PlateSlateWeb.Resolvers.Menu do
  alias PlateSlate.Menu

  def items(_, args, _) do
    {:ok, Menu.list_items(args)}
  end

  def categories(_, args, _) do
    {:ok, Menu.list_categories(args)}
  end
end
