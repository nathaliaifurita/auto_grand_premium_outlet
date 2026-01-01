# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
#   @moduledoc """
#   Lists available vehicles ordered by price (ascending).
#   """

#   alias AutoGrandPremiumOutlet.Domain.Vehicle
#   alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

#   @spec execute(VehicleRepository.t()) :: {:ok, [Vehicle.t()]} | {:error, :persistence_error}
#   def execute(vehicle_repo) do
#     case vehicle_repo.list_available_ordered_by_price()
#          |> Enum.sort_by(& &1.price, :asc) do
#       {:ok, vehicles} -> {:ok, vehicles}
#       {:error, :not_found} -> {:error, :vehicle_not_found}
#     end
#   end

#   # @spec execute(module()) :: list(Vehicle.t())
#   # def execute(vehicle_repo) do
#   #   vehicle_repo.list_available_ordered_by_price()
#   #   |> Enum.sort_by(& &1.price)
#   # end
# end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: list(Vehicle.t())
#   def execute(vehicle_repo) do
#     vehicle_repo.list_available_ordered_by_price()
#     |> Enum.sort_by(& &1.price)
#   end
# end

# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec execute(module()) :: {:ok, list(Vehicle.t())}
#   def execute(vehicle_repo) do
#     vehicles =
#       vehicle_repo.list_available_ordered_by_price()
#       |> Enum.sort_by(& &1.price(:asc))

#     {:ok, vehicles}
#   end
# end

defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  def execute(vehicle_repo) do
    vehicle_repo.list_available_ordered_by_price()
    |> Enum.sort_by(& &1.price, :asc)
    |> then(&{:ok, &1})
  end
end
