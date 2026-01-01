defmodule AutoGrandPremiumOutlet.UseCases.Payments.CancelPaymentTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Payments.CancelPayment
  alias AutoGrandPremiumOutlet.Domain.Payment

  ## -------- Fakes --------

  defmodule FakePaymentRepo do
    def get_by_payment_code("pay-ok") do
      {:ok,
       %Payment{
         id: "pay-1",
         payment_code: "pay-ok",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code("pay-paid") do
      {:ok,
       %Payment{
         id: "pay-2",
         payment_code: "pay-paid",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :paid,
         inserted_at: DateTime.utc_now(),
         updated_at: DateTime.utc_now()
       }}
    end

    def get_by_payment_code("pay-cancelled") do
      {:ok,
       %Payment{
         id: "pay-3",
         payment_code: "pay-cancelled",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :cancelled,
         inserted_at: DateTime.utc_now(),
         updated_at: DateTime.utc_now()
       }}
    end

    def get_by_payment_code("pay-not-found"),
      do: {:error, :not_found}

    def update(%Payment{} = payment),
      do: {:ok, payment}
  end

  defmodule FailingPaymentRepo do
    def get_by_payment_code("boom") do
      {:ok,
       %Payment{
         id: "pay-4",
         payment_code: "boom",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def update(_), do: {:error, :persistence_error}
  end

  ## -------- Tests --------

  test "successfully cancel payment :in_process" do
    assert {:ok, %Payment{} = payment} =
             CancelPayment.execute("pay-ok", FakePaymentRepo)

    assert payment.payment_status == :cancelled
    assert %DateTime{} = payment.updated_at
  end

  test "returns error when payment is not found" do
    assert {:error, :payment_not_found} =
             CancelPayment.execute("pay-not-found", FakePaymentRepo)
  end

  test "returns error when the payment is already :paid" do
    assert {:error, :payment_already_paid} =
             CancelPayment.execute("pay-paid", FakePaymentRepo)
  end

  test "returns error when the payment is already :cancelled" do
    assert {:error, :payment_already_cancelled} =
             CancelPayment.execute("pay-cancelled", FakePaymentRepo)
  end

  test "returns persistence error when fails to cancel" do
    assert {:error, :persistence_error} =
             CancelPayment.execute("boom", FailingPaymentRepo)
  end
end
