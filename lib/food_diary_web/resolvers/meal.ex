defmodule FoodDiaryWeb.Resolvers.Meal do
  alias Absinthe.Subscription
  alias FoodDiaryWeb.Endpoint
  alias FoodDiary.Meals

  # def create(%{input: params}, _context) do
  #   with {:ok, meal} <- Meals.Create.call(params) do
  #     Subscription.publish(Endpoint, meal, new_meal: "new_meal_topic")
  #     {:ok, meal}
  #   else
  #     error -> error
  #   end
  # end

  def create(%{input: params}, _context), do: Meals.Create.call(params)

  # def delete(%{id: meal_id}, _context), do: Meals.Delete.call(meal_id)
  # def get(%{id: meal_id}, _context), do: Meals.Get.call(meal_id)
end
