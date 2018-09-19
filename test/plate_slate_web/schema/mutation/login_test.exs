defmodule PlateSlateWeb.Schema.Query.LoginTest do
  use PlateSlateWeb.ConnCase, async: true

  @query """
  mutation ($email: String!) {
    login(role: EMPLOYEE, email: $email, password: "super-secret") {
      token
      user { name }
    }
  }
  """
  test "creating an employee session", %{conn: conn} do
    user = TestSupport.Factory.create_user("employee")
    response = post(conn, "/api", %{query: @query, variables: %{email: user.email}})

    assert %{
             "data" => %{
               "login" => %{
                 "token" => token,
                 "user" => user_data
               }
             }
           } = json_response(response, 200)

    assert %{"name" => user.name} == user_data
    verification = PlateSlateWeb.Authentication.verify(token)
    assert {:ok, %{role: :employee, id: user.id}} == verification
  end
end
