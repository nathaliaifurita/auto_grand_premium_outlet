defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListAvailableVehicles do
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  def execute(vehicle_repo) do
    vehicle_repo.list_available_ordered_by_price()
    |> Enum.sort_by(& &1.price, :asc)
    |> then(&{:ok, &1})
  end
end
