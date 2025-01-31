defmodule FoodDiaryWeb.SchemaTest do
  use FoodDiaryWeb.ConnCase, async: true
  use FoodDiaryWeb.SubscriptionCase

  alias FoodDiary.User
  alias FoodDiary.Users

  describe "users query" do
    test "when a valid id is given, returns the user", %{conn: conn} do
      params = %{email: "mail@email.com", name: "Mingyar"}

      {:ok, %User{id: user_id}} = Users.Create.call(params)

      query = """
      {
        user(id: "#{user_id}"){
          name,
          email
        }
      }
      """

      expected_response = %{
        "data" => %{"user" => %{"email" => "mail@email.com", "name" => "Mingyar"}}
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end

    test "when the user does not exist, returns an error", %{conn: conn} do
      query = """
      {
        user(id: "123456"){
          name,
          email
        }
      }
      """

      expected_response = %{
        "data" => %{"user" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 3, "line" => 2}],
            "message" => "User not found",
            "path" => ["user"]
          }
        ]
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end
  end

  describe "users mutation" do
    test "when all params are valid, creates the user", %{conn: conn} do
      mutation = """
        mutation {
          createUser(
            input: {
             email: "mail@email.com",
             name: "Mingyar"
            }
          ){
            id
            name
            email
          }
        }
      """

      response =
        conn
        |> post("api/graphql", %{query: mutation})
        |> json_response(:ok)

      assert %{
               "data" => %{
                 "createUser" => %{
                   "email" => "mail@email.com",
                   "id" => _id,
                   "name" => "Mingyar"
                 }
               }
             } = response
    end
  end

  describe "subscriptions" do
    test "meals subsription", %{socket: socket} do
      params = %{email: "mail@email.com", name: "Mingyar"}

      {:ok, %User{id: user_id}} = Users.Create.call(params)

      mutation = """
        mutation {
          createMeal(
            input: {
             userId: #{user_id},
             description: "Pizza",
             calories: 370.50,
             category: FOOD
            }
          ){
            description
            calories
            category
          }
        }
      """

      subscription = """
        subscription {
          newMeal{
            description
          }
        }
      """

      # subscription setup
      socket_ref = push_doc(socket, subscription)
      assert_reply socket_ref, :ok, %{subscriptionId: subscription_id}

      # mutation setup
      socket_ref = push_doc(socket, mutation)
      assert_reply socket_ref, :ok, mutation_response

      expected_mutation_response = %{
        data: %{
          "createMeal" => %{
            "calories" => 370.5,
            "category" => "FOOD",
            "description" => "Pizza"
          }
        }
      }

      expected_subscription_response = %{
        result: %{data: %{"newMeal" => %{"description" => "Pizza"}}},
        subscriptionId: subscription_id
      }

      assert mutation_response == expected_mutation_response

      assert_push "subscription:data", subscription_response
      assert subscription_response == expected_subscription_response
    end
  end
end
