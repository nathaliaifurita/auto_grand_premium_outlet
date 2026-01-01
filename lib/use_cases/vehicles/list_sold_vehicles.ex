# # defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
# #   @moduledoc """
# #   Lists sold vehicles ordered by price (ascending).
# #   """

# #   @spec execute(module()) :: {:ok, list()} | {:error, term()}
# #   def execute(vehicle_repo) do
# #     vehicles =
# #       vehicle_repo.list_sold()
# #       |> Enum.sort_by(& &1.price)

# #     {:ok, vehicles}
# #   end
# # end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
#   @moduledoc """
#   Lists sold vehicles ordered by price (ascending).
#   """

#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: list(Vehicle.t())
#   def execute(vehicle_repo) do
#     case vehicle_repo.list_sold()
#          |> Enum.sort_by(& &1.price, :asc) do
#       {:ok, vehicles} -> {:ok, vehicles}
#       {:error, :not_found} -> {:error, :vehicle_not_found}
#     end
#   end
# end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: list(Vehicle.t())
#   def execute(vehicle_repo) do
#     vehicle_repo.list_sold()
#     |> Enum.sort_by(& &1.price)
#   end
# end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: {:ok, list(Vehicle.t())}
#   def execute(vehicle_repo) do
#     vehicles =
#       vehicle_repo.list_sold()
#       |> Enum.sort_by(& &1.price(:asc))

#     {:ok, vehicles}
#   end
# end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: {:ok, list(Vehicle.t())}
#   def execute(vehicle_repo) do
#     vehicle_repo.list_sold()
#     |> Enum.sort_by(& &1.price, :asc)
#     |> then(&{:ok, &1})
#   end
# end
defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
  def execute(vehicle_repo) do
    vehicles =
      vehicle_repo.list_sold()
      |> Enum.sort_by(& &1.price, :asc)

    {:ok, vehicles}
  end
end
