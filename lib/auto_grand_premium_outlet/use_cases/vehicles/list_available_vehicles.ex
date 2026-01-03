defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
  @moduledoc """
  Use case for listing available vehicles ordered by price.
  Sorting is handled by the repository (data access concern).
  """

  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  @spec execute(VehicleRepository.t()) ::
          {:ok, [AutoGrandPremiumOutlet.Domain.Vehicle.t()]} | {:error, :not_found}
  def execute(vehicle_repo) do
    # Sorting is handled by the repository as it's a data access concern
    vehicle_repo.list_available_ordered_by_price()
  end
end
