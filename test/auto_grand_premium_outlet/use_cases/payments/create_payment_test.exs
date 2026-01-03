defmodule AutoGrandPremiumOutlet.UseCases.Payments.CreatePaymentTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Payments.CreatePayment
  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  ## -------- Fake Repositories --------

  defmodule FakePaymentRepo do
    def save(%Payment{} = payment), do: {:ok, payment}
  end

  defmodule FailingPaymentRepo do
    def save(_), do: {:error, :db_down}
  end

  defmodule FakeSaleRepo do
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
  end

  defmodule SoldSaleRepo do
    def get("sale-completed") do
      {:ok,
       %Sale{
         id: "sale-completed",
         vehicle_id: "vehicle-9",
         buyer_cpf: "12345678901",
         status: :completed,
         inserted_at: DateTime.utc_now()
       }}
    end
  end

  defmodule IdGeneratorMock do
    def generate, do: "test-payment-id-123"
  end

  defmodule CodeGeneratorMock do
    def generate, do: "TEST-CODE-123"
  end

  defmodule ClockMock do
    def now, do: DateTime.utc_now()
  end

  ## -------- Tests --------

  test "creates a successfull payment when sales is valid" do
    attrs = %{
      # payment_code: payment_code,
      sale_id: "sale-1",
      amount: 50_000
    }

    assert {:ok, %Payment{} = payment} =
             CreatePayment.execute(
               attrs,
               FakePaymentRepo,
               FakeSaleRepo,
               IdGeneratorMock,
               CodeGeneratorMock,
               ClockMock
             )

    # assert payment.payment_code == payment.payment_code
    assert payment.sale_id == "sale-1"
    assert payment.amount == 50_000
    assert payment.payment_status == :in_process
    assert %DateTime{} = payment.inserted_at
  end

  test "returns error when amount is invalid" do
    attrs = %{
      payment_code: "pay-999",
      sale_id: "sale-1",
      amount: 0
    }

    assert {:error, :invalid_amount} =
             CreatePayment.execute(
               attrs,
               FailingPaymentRepo,
               FakeSaleRepo,
               IdGeneratorMock,
               CodeGeneratorMock,
               ClockMock
             )
  end

  test "returns persistence error when payment is not save" do
    attrs = %{
      payment_code: "pay-999",
      sale_id: "sale-1",
      amount: 100_000
    }

    assert {:error, :persistence_error} =
             CreatePayment.execute(
               attrs,
               FailingPaymentRepo,
               FakeSaleRepo,
               IdGeneratorMock,
               CodeGeneratorMock,
               ClockMock
             )
  end
end
