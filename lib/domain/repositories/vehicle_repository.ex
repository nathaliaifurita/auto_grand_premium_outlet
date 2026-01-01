defmodule AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository do
  @moduledoc """
  Repository port for Vehicle persistence.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  @type error :: :not_found | :invalid_sale_state | :vehicle_already_sold | :persistence_error

  @callback create(Sale.t()) :: {:ok, Vehicle.t()} | {:error, term()}

  @callback get(String.t()) :: {:ok, Vehicle.t()} | {:error, :not_found}

  @callback list_available_ordered_by_price() :: list(Vehicle.t())
  @callback list_sold() :: list(Vehicle.t())

  @callback update(Vehicle.t()) ::
              {:ok, Vehicle.t()} | {:error, error()}
end
