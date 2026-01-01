defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.GetVehicleTest do
  use ExUnit.Case

  alias AutoGrandPremiumOutlet.UseCases.Vehicles.GetVehicle
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  defmodule FakeVehicleRepo do
    def get("vehicle-1") do
      {:ok,
       %Vehicle{
         id: "vehicle-1",
         brand: "Ford",
         model: "Ka",
         year: 2020,
         color: "Preto",
         price: 30_000,
         license_plate: "ABC1D23",
         status: :available,
         inserted_at: DateTime.utc_now(),
         updated_at: nil,
         sold_at: nil
       }}
    end

    def get(_id), do: {:error, :not_found}
  end

  test "returns vehicle when found" do
    assert {:ok, vehicle} =
             GetVehicle.execute("vehicle-1", FakeVehicleRepo)

    assert vehicle.id == "vehicle-1"
    assert vehicle.brand == "Ford"
    assert vehicle.status == :available
  end

  test "returns error when vehicle is not found" do
    assert {:error, :vehicle_not_found} =
             GetVehicle.execute("invalid-id", FakeVehicleRepo)
  end
end
