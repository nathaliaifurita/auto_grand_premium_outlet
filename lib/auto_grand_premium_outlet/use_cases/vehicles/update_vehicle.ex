defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.UpdateVehicle do
  @moduledoc """
  Updates vehicle information applying business rules.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository
  alias AutoGrandPremiumOutlet.Domain.Services.Clock
  alias AutoGrandPremiumOutlet.UseCases.ParamsNormalizer

  @type error ::
          :vehicle_not_found
          | :invalid_year
          | :invalid_price
          | :invalid_license_plate
          | :persistence_error

  @spec execute(
          String.t(),
          map(),
          VehicleRepository.t(),
          Clock.t()
        ) :: {:ok, Vehicle.t()} | {:error, error()}
  def execute(id, attrs, vehicle_repo, clock) do
    # Normalize parameters (string keys to atoms)
    normalized_attrs = ParamsNormalizer.normalize_vehicle_params(attrs)

    with {:ok, vehicle} <- fetch_vehicle(id, vehicle_repo),
         {:ok, updated_vehicle} <- Vehicle.update(vehicle, normalized_attrs, clock.now()),
         {:ok, persisted_vehicle} <- vehicle_repo.update(updated_vehicle) do
      {:ok, persisted_vehicle}
    else
      {:error, :not_found} -> {:error, :vehicle_not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  ## -------- helpers --------

  defp fetch_vehicle(id, repo) do
    case repo.get(id) do
      {:ok, vehicle} -> {:ok, vehicle}
      {:error, :not_found} -> {:error, :not_found}
    end
  end
end
