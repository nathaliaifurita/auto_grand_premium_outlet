defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
  @moduledoc """
  Use case for listing sold vehicles ordered by price.
  Sorting is handled by the repository (data access concern).
  Filtering by status is done here to ensure only sold vehicles are returned.
  """

  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository
  alias AutoGrandPremiumOutlet.UseCases.Vehicles.VehicleFilter

  @spec execute(VehicleRepository.t()) ::
          {:ok, [AutoGrandPremiumOutlet.Domain.Vehicle.t()]} | {:error, :not_found}
  def execute(vehicle_repo) do
    with {:ok, vehicles} <- vehicle_repo.list_sold() do
      sold_vehicles = VehicleFilter.filter_by_status(vehicles, :sold)
      {:ok, sold_vehicles}
    end
  end
end
