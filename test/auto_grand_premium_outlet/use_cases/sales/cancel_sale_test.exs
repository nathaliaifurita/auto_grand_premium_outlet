defmodule AutoGrandPremiumOutlet.UseCases.Sales.CancelSaleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Sales.CancelSale
  alias AutoGrandPremiumOutlet.Domain.Sale

  ## -------- Fakes --------

  defmodule FakeSaleRepo do
    def get("sale-initiated") do
      {:ok,
       %Sale{
         id: "sale-initiated",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("sale-completed") do
      {:ok,
       %Sale{
         id: "sale-completed",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :completed,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("sale-cancelled") do
      {:ok,
       %Sale{
         id: "sale-cancelled",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :cancelled,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("sale-not-found"), do: {:error, :not_found}

    def update(%Sale{} = sale), do: {:ok, sale}
  end

  defmodule FailingSaleRepo do
    def get("sale-initiated") do
      {:ok,
       %Sale{
         id: "sale-initiated",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(_sale), do: {:error, :db_error}
  end

  defmodule ClockMock do
    def now, do: DateTime.utc_now()
  end

  ## -------- Tests --------

  test "successfully cancels a sale initiated" do
    assert {:ok, sale} =
             CancelSale.execute(
               "sale-initiated",
               FakeSaleRepo,
               ClockMock
             )

    assert sale.status == :cancelled
  end

  test "returns error when sale is not found" do
    assert {:error, :sale_not_found} =
             CancelSale.execute(
               "sale-not-found",
               FakeSaleRepo,
               ClockMock
             )
  end

  test "returns error when sale is already completed" do
    assert {:error, :invalid_sale_state} =
             CancelSale.execute(
               "sale-completed",
               FakeSaleRepo,
               ClockMock
             )
  end

  test "returns error when sale is already cancelled" do
    assert {:error, :invalid_sale_state} =
             CancelSale.execute(
               "sale-cancelled",
               FakeSaleRepo,
               ClockMock
             )
  end

  test "returns persistence_error when repository update fails" do
    assert {:error, :persistence_error} =
             CancelSale.execute(
               "sale-initiated",
               FailingSaleRepo,
               ClockMock
             )
  end
end
