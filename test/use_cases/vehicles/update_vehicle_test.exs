defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.UpdateVehicleTest do
  use ExUnit.Case

  alias AutoGrandPremiumOutlet.UseCases.Vehicles.UpdateVehicle
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  defmodule FakeVehicleRepo do
    def get("vehicle-1") do
      {:ok,
       %Vehicle{
         id: "vehicle-1",
         brand: "Toyota",
         model: "Corolla",
         year: 2020,
         color: "Preto",
         price: 100_000,
         license_plate: "ABC1D23",
         status: :available,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get(_id), do: {:error, :not_found}

    # 🔑 ESSENCIAL: retornar o veículo atualizado
    def update(%Vehicle{} = vehicle), do: {:ok, vehicle}
  end

  test "successfully updates vehicle information" do
    attrs = %{
      color: "Vermelho",
      price: 120_000
    }

    assert {:ok, updated_vehicle} =
             UpdateVehicle.execute("vehicle-1", attrs, FakeVehicleRepo)

    assert updated_vehicle.color == "Vermelho"
    assert updated_vehicle.price == 120_000
    assert updated_vehicle.updated_at != nil
  end

  test "returns error when vehicle is not found" do
    assert {:error, :vehicle_not_found} =
             UpdateVehicle.execute("unknown-id", %{color: "Azul"}, FakeVehicleRepo)
  end

  test "returns error when year is invalid" do
    assert {:error, :invalid_year} =
             UpdateVehicle.execute("vehicle-1", %{year: 1700}, FakeVehicleRepo)
  end

  test "returns error when price is invalid" do
    assert {:error, :invalid_price} =
             UpdateVehicle.execute("vehicle-1", %{price: -10}, FakeVehicleRepo)
  end

  test "returns error when license plate is invalid" do
    assert {:error, :invalid_license_plate} =
             UpdateVehicle.execute("vehicle-1", %{license_plate: "123"}, FakeVehicleRepo)
  end
end
