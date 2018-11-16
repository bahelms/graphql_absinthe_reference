defmodule PlateSlateWeb.Schema.Subscription.NewOrderTest do
  use PlateSlateWeb.SubscriptionCase

  @subscription """
  subscription {
    newOrder {
      customerNumber
    }
  }
  """
  @mutation """
  mutation ($input: PlaceOrderInput!) {
    placeOrder(input: $input) { order { id } }
  }
  """
  test "new orders can be subscribed to", %{socket: socket} do
    # Login
    user = TestSupport.Factory.create_user("employee")
    ref = login(socket, user.email, user.role)
    timeout = 1_000
    assert_reply(ref, :ok, %{data: %{"login" => %{"token" => _}}}, timeout)

    # Set up subscription
    ref = push_doc(socket, @subscription)
    assert_reply(ref, :ok, %{subscriptionId: subscription_id})

    order_input = %{
      "customerNumber" => 24,
      "items" => [%{"quantity" => 2, "menuItemId" => menu_item("Reuben").id}]
    }

    # Trigger subscription
    ref = push_doc(socket, @mutation, variables: %{input: order_input})
    assert_reply(ref, :ok, reply)
    assert %{data: %{"placeOrder" => %{"order" => %{"id" => _}}}} = reply

    assert_push("subscription:data", push)

    assert push == %{
             result: %{data: %{"newOrder" => %{"customerNumber" => 24}}},
             subscriptionId: subscription_id
           }
  end

  test "customers can't see other customer orders", %{socket: socket} do
    bob = TestSupport.Factory.create_user("customer")
    ref = login(socket, bob.email, bob.role)
    assert_reply(ref, :ok, %{data: %{"login" => %{"token" => _}}}, 1_000)

    ref = push_doc(socket, @subscription)
    assert_reply(ref, :ok, %{subscriptionId: _subscription_id})
    place_order(bob)
    assert_push("subscription:data", _)

    joe = TestSupport.Factory.create_user("customer")
    place_order(joe)
    refute_receive(_)
  end

  defp login(socket, email, role) do
    login_query = """
    mutation ($email: String!, $role: Role!) {
      login(role: $role, email: $email, password: "super-secret") {
        token
      }
    }
    """

    push_doc(
      socket,
      login_query,
      variables: %{"email" => email, "role" => String.upcase(role)}
    )
  end

  defp place_order(customer) do
    order_input = %{
      "customer_number" => 24,
      "items" => [%{"quantity" => 2, "menuItemId" => menu_item("Reuben").id}]
    }

    {:ok, %{data: %{"placeOrder" => _}}} =
      Absinthe.run(
        @mutation,
        PlateSlateWeb.Schema,
        context: %{current_user: customer},
        variables: %{"input" => order_input}
      )
  end
end
