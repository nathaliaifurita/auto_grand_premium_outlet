defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.GetVehicle do
  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  @type error :: :vehicle_not_found

  @spec execute(String.t(), VehicleRepository.t()) ::
          {:ok, Vehicle.t()} | {:error, error()}
  def execute(vehicle_id, repo) do
    case repo.get(vehicle_id) do
      {:ok, %Vehicle{} = vehicle} ->
        {:ok, vehicle}

      {:error, :not_found} ->
        {:error, :vehicle_not_found}
    end
  end
end
