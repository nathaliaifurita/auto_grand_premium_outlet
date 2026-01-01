defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.ListSoldVehicles do
  def execute(vehicle_repo) do
    vehicles =
      vehicle_repo.list_sold()
      |> Enum.sort_by(& &1.price, :asc)

    {:ok, vehicles}
  end
end
