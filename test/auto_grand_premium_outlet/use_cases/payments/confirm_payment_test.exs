defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPaymentTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment
  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale, Vehicle}

  ## -------- Fake Payment Repos --------

  defmodule PaymentRepoOk do
    def get_by_payment_code("pay-ok") do
      {:ok,
       %Payment{
         id: "p1",
         payment_code: "pay-ok",
         sale_id: "sale-1",
         amount: 100_000,
         payment_status: :in_process,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(payment), do: {:ok, payment}
  end

  defmodule PaymentRepoPaid do
    def get_by_payment_code("pay-paid") do
      {:ok,
       %Payment{
         id: "p2",
         payment_code: "pay-paid",
         sale_id: "sale-1",
         amount: 100_000,
         payment_status: :paid,
         inserted_at: DateTime.utc_now()
       }}
    end
  end

  defmodule PaymentRepoNotFound do
    def get_by_payment_code(_), do: {:error, :not_found}
  end

  ## -------- Fake Sale Repos --------

  defmodule SaleRepoInitiated do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(sale), do: {:ok, sale}
  end

  defmodule SaleRepoCompleted do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :completed,
         inserted_at: DateTime.utc_now()
       }}
    end
  end

  defmodule SaleRepoNotFound do
    def get(_), do: {:error, :not_found}
  end

  ## -------- Fake Vehicle Repos --------

  defmodule VehicleRepoOk do
    def get("vehicle-1") do
      {:ok,
       %Vehicle{
         id: "vehicle-1",
         brand: "Toyota",
         model: "Corolla",
         year: 2022,
         color: "Preto",
         price: 100_000,
         license_plate: "ABC1234",
         status: :available,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(vehicle), do: {:ok, vehicle}
  end

  defmodule VehicleRepoNotFound do
    def get(_), do: {:error, :not_found}
  end

  defmodule ClockMock do
    def now, do: DateTime.utc_now()
  end

  ## -------- Tests --------

  test "successfully confirms payment and completes sale" do
    assert {:ok, payment} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoInitiated,
               VehicleRepoOk,
               ClockMock
             )

    assert payment.payment_status == :paid
  end

  test "returns error when payment is not found" do
    assert {:error, :payment_not_found} =
             ConfirmPayment.execute(
               "pay-x",
               PaymentRepoNotFound,
               SaleRepoInitiated,
               VehicleRepoOk,
               ClockMock
             )
  end

  test "returns error when payment is already paid" do
    assert {:error, :payment_already_paid} =
             ConfirmPayment.execute(
               "pay-paid",
               PaymentRepoPaid,
               SaleRepoInitiated,
               VehicleRepoOk,
               ClockMock
             )
  end

  test "returns error when sale is not found" do
    assert {:error, :sale_not_found} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoNotFound,
               VehicleRepoOk,
               ClockMock
             )
  end

  test "returns error when sale is already completed" do
    assert {:error, :sale_already_completed} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoCompleted,
               VehicleRepoOk,
               ClockMock
             )
  end

  test "returns error when vehicle is not found" do
    assert {:error, :vehicle_not_found} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoInitiated,
               VehicleRepoNotFound,
               ClockMock
             )
  end
end
