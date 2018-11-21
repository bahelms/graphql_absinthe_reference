defmodule PlateSlate.Repo.Migrations.CreateOrderItemView do
  use Ecto.Migration

  def up do
    execute("""
    CREATE VIEW order_items AS
    SELECT I.*, O.id AS order_id
    FROM orders O,
      jsonb_to_recordset(O.items) I(name text, quantity int, price float, id text)
    """)
  end

  def down do
    execute("DROP VIEW order_items")
  end
end
