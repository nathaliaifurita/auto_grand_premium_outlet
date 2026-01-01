defmodule AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository do
  @moduledoc """
  Repository port for Vehicle persistence.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  @type error :: :not_found | :invalid_sale_state | :vehicle_already_sold | :persistence_error

  @callback save(Sale.t()) :: {:ok, Vehicle.t()} | {:error, term()}

  @callback get(String.t()) :: {:ok, Vehicle.t()} | {:error, :not_found}

  @callback list() :: [Vehicle.t()]
  @callback list_sold() :: [Vehicle.t()]
  @callback list_available_ordered_by_price() ::
              {:ok, [Vehicle.t()]} | {:error, :not_found}

  @callback update(Vehicle.t()) ::
              {:ok, Vehicle.t()} | {:error, error()}
end
