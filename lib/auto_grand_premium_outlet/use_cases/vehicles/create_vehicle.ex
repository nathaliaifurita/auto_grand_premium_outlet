defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicle do
  @moduledoc """
  Use case for creating a new vehicle.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  @type error ::
          :invalid_year
          | :invalid_price
          | :invalid_license_plate
          | :persistence_error

  @spec execute(map(), VehicleRepository.t()) ::
          {:ok, Vehicle.t()} | {:error, error()}
  def execute(attrs, vehicle_repo) do
    with {:ok, vehicle} <- Vehicle.new(attrs),
         {:ok, vehicle} <- vehicle_repo.save(vehicle) do
      {:ok, vehicle}
    else
      {:error, reason} ->
        {:error, map_error(reason)}
    end
  end

  ## -------- helpers --------

  defp map_error(:invalid_year), do: :invalid_year
  defp map_error(:invalid_price), do: :invalid_price
  defp map_error(:invalid_license_plate), do: :invalid_license_plate
  defp map_error(_), do: :persistence_error
end
