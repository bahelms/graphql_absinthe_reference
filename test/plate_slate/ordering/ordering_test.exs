defmodule PlateSlate.OrderingTest do
  use PlateSlate.DataCase
  alias PlateSlate.Ordering
  alias PlateSlate.Menu

  setup do
    PlateSlate.Seeds.run()
  end

  describe "orders" do
    alias PlateSlate.Ordering.Order

    test "create_order/1 with valid data creates an order" do
      chai = Repo.get_by!(Menu.Item, name: "Masala Chai")
      fries = Repo.get_by!(Menu.Item, name: "French Fries")

      attrs = %{
        ordered_at: "2010-04-17 14:00:00.000000Z",
        state: "created",
        items: [
          %{menu_item_id: chai.id, quantity: 1},
          %{menu_item_id: fries.id, quantity: 2}
        ]
      }

      assert {:ok, %Order{} = order} = Ordering.create_order(attrs)
      items = Enum.map(order.items, &Map.take(&1, [:name, :quantity, :price]))

      assert items == [
               %{name: "Masala Chai", quantity: 1, price: chai.price},
               %{name: "French Fries", quantity: 2, price: fries.price}
             ]
    end
  end
end
