defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
  @moduledoc """
  Use case for listing available vehicles ordered by price.
  Sorting is handled by the repository (data access concern).
  Filtering by status is done here to ensure only available vehicles are returned.
  """

  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository
  alias AutoGrandPremiumOutlet.UseCases.Vehicles.VehicleFilter

  @spec execute(VehicleRepository.t()) ::
          {:ok, [AutoGrandPremiumOutlet.Domain.Vehicle.t()]} | {:error, :not_found}
  def execute(vehicle_repo) do
    with {:ok, vehicles} <- vehicle_repo.list_available_ordered_by_price() do
      available_vehicles = VehicleFilter.filter_by_status(vehicles, :available)
      {:ok, available_vehicles}
    end
  end
end
