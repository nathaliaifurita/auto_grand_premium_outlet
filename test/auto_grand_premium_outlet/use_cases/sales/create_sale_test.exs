defmodule AutoGrandPremiumOutlet.UseCases.Sales.CreateSaleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Sales.CreateSale
  alias AutoGrandPremiumOutlet.Domain.{Vehicle, Sale}

  ## -------- fakes --------

  defmodule FakeVehicleRepo do
    def get("vehicle-1") do
      {:ok,
       %Vehicle{
         id: "vehicle-1",
         brand: "VW",
         model: "Gol",
         year: 2020,
         color: "preto",
         price: 50_000,
         license_plate: "ABC1D23",
         status: :available
       }}
    end

    def get(_), do: {:error, :not_found}

    def update(vehicle), do: {:ok, vehicle}
  end

  defmodule SoldVehicleRepo do
    def get(_id) do
      {:ok,
       %Vehicle{
         id: "vehicle-2",
         brand: "Ford",
         model: "Fusion",
         year: 2020,
         color: "black",
         price: 100_000,
         license_plate: "ABC1D23",
         status: :sold,
         inserted_at: DateTime.utc_now(),
         updated_at: nil,
         sold_at: DateTime.utc_now()
       }}
    end

    def update(_vehicle), do: {:error, :should_not_be_called}
  end

  defmodule FakeSaleRepo do
    def create(%Sale{buyer_cpf: "INVALID"}), do: {:error, :invalid_cpf}
    def create(%Sale{} = sale), do: {:ok, sale}
  end

  ## -------- tests --------

  test "creates a sale when vehicle is available" do
    assert {:ok, %Sale{} = sale} =
             CreateSale.execute(
               "vehicle-1",
               "12345678909",
               FakeVehicleRepo,
               FakeSaleRepo
             )

    assert sale.vehicle_id == "vehicle-1"
    assert sale.buyer_cpf == "12345678909"
  end

  test "returns error when vehicle does not exist" do
    assert {:error, :vehicle_not_found} =
             CreateSale.execute(
               "invalid-id",
               "12345678909",
               FakeVehicleRepo,
               FakeSaleRepo
             )
  end

  test "returns error when cpf is invalid" do
    assert {:error, :invalid_cpf} =
             CreateSale.execute(
               "vehicle-1",
               "123",
               FakeVehicleRepo,
               FakeSaleRepo
             )
  end

  test "returns error when vehicle has already been sold" do
    assert {:error, :vehicle_already_sold} =
             CreateSale.execute(
               "vehicle-2",
               "12345678901",
               SoldVehicleRepo,
               FakeSaleRepo
             )
  end
end
