defmodule AutoGrandPremiumOutlet.UseCases.Sales.CompleteSaleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Sales.CompleteSale
  alias AutoGrandPremiumOutlet.Domain.{Sale, Vehicle}

  ## -------- Fakes --------

  defmodule FakeSaleRepo do
    def get("sale-ok") do
      {:ok,
       %Sale{
         id: "sale-ok",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("sale-invalid-state") do
      {:ok,
       %Sale{
         id: "sale-invalid-state",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :completed,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("sale-not-found"), do: {:error, :not_found}

    def update(%Sale{} = sale), do: {:ok, sale}
  end

  defmodule FakeVehicleRepo do
    def get("vehicle-1") do
      {:ok,
       %Vehicle{
         id: "vehicle-1",
         brand: "VW",
         model: "Gol",
         year: 2020,
         color: "Preto",
         price: 50_000,
         license_plate: "ABC1D23",
         status: :available,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("vehicle-sold") do
      {:ok,
       %Vehicle{
         id: "vehicle-sold",
         brand: "VW",
         model: "Gol",
         year: 2020,
         color: "Preto",
         price: 50_000,
         license_plate: "ABC1D23",
         status: :sold,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(%Vehicle{} = vehicle), do: {:ok, vehicle}
  end

  defmodule VehicleAlreadySoldSaleRepo do
    def get("sale-ok") do
      {:ok,
       %Sale{
         id: "sale-ok",
         vehicle_id: "vehicle-sold",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(sale), do: {:ok, sale}
  end

  defmodule VehicleAlreadySoldVehicleRepo do
    def get("vehicle-sold") do
      {:ok,
       %Vehicle{
         id: "vehicle-sold",
         brand: "VW",
         model: "Gol",
         year: 2020,
         color: "Preto",
         price: 50_000,
         license_plate: "ABC1D23",
         status: :sold,
         inserted_at: DateTime.utc_now(),
         sold_at: DateTime.utc_now()
       }}
    end

    def update(vehicle), do: {:ok, vehicle}
  end

  defmodule ClockMock do
    def now, do: DateTime.utc_now()
  end

  ## -------- Tests --------

  test "successfully completes a sale" do
    assert {:ok, sale} =
             CompleteSale.execute(
               "sale-ok",
               FakeSaleRepo,
               FakeVehicleRepo,
               ClockMock
             )

    assert sale.status == :completed
  end

  test "returns error when sale is not found" do
    assert {:error, :sale_not_found} =
             CompleteSale.execute(
               "sale-not-found",
               FakeSaleRepo,
               FakeVehicleRepo,
               ClockMock
             )
  end

  test "returns error when sale is not in process" do
    assert {:error, :invalid_sale_state} =
             CompleteSale.execute(
               "sale-invalid-state",
               FakeSaleRepo,
               FakeVehicleRepo,
               ClockMock
             )
  end

  test "returns error when vehicle is already sold" do
    assert {:error, :vehicle_already_sold} =
             CompleteSale.execute(
               "sale-ok",
               VehicleAlreadySoldSaleRepo,
               VehicleAlreadySoldVehicleRepo,
               ClockMock
             )
  end
end
