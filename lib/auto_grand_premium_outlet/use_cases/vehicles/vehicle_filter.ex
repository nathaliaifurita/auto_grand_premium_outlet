defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.VehicleFilter do
  @moduledoc """
  Helper module for filtering vehicles by status.
  Centralizes filtering logic to avoid duplication.
  """

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  @doc """
  Filters vehicles by status.
  """
  @spec filter_by_status([Vehicle.t()], :available | :sold) :: [Vehicle.t()]
  def filter_by_status(vehicles, status) when status in [:available, :sold] do
    Enum.filter(vehicles, &(&1.status == status))
  end
end
