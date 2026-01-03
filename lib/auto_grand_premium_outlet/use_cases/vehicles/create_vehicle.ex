defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicle do
  @moduledoc """
  Use case for creating a new vehicle.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository
  alias AutoGrandPremiumOutlet.Domain.Services.IdGenerator
  alias AutoGrandPremiumOutlet.UseCases.ParamsNormalizer

  @type error ::
          :invalid_year
          | :invalid_price
          | :invalid_license_plate
          | :invalid_id
          | :persistence_error

  @spec execute(map(), VehicleRepository.t(), IdGenerator.t()) ::
          {:ok, Vehicle.t()} | {:error, error()}
  def execute(attrs, vehicle_repo, id_generator) do
    # Normalize parameters (string keys to atoms, string values to integers)
    normalized_attrs = ParamsNormalizer.normalize_vehicle_params(attrs)

    # Always generate a new ID, ignoring any ID that might come in attrs
    attrs_with_id =
      normalized_attrs
      |> Map.delete(:id)
      |> Map.put(:id, id_generator.generate())

    with {:ok, vehicle} <- Vehicle.new(attrs_with_id),
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
  defp map_error(:id_required), do: :persistence_error
  defp map_error(:invalid_id), do: :invalid_id
  defp map_error(_), do: :persistence_error
end
