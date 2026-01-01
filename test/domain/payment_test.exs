defmodule AutoGrandPremiumOutlet.Domain.PaymentTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.Domain.Payment

  describe "new/1" do
    test "creates a new payment :in_process" do
      attrs = %{
        sale_id: "sale-1",
        amount: 100_000
      }

      assert {:ok, %Payment{} = payment} = Payment.new(attrs)

      assert payment.id != nil
      assert payment.payment_code != nil
      assert payment.sale_id == "sale-1"
      assert payment.amount == 100_000
      assert payment.payment_status == :in_process
      assert %DateTime{} = payment.inserted_at
      assert payment.updated_at == nil
    end

    test "returns error when the sale_id is nil" do
      attrs = %{
        payment_code: "pay-123",
        sale_id: "",
        amount: 100_000
      }

      assert {:error, :invalid_sale_id} = Payment.new(attrs)
    end

    test "returns error when the amount is below 0" do
      attrs = %{
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: -10
      }

      assert {:error, :invalid_amount} = Payment.new(attrs)
    end

    test "does not allow to create payment with a informed state" do
      attrs = %{
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: 100_000,
        payment_status: :paid
      }

      assert {:ok, payment} = Payment.new(attrs)
      assert payment.payment_status == :in_process
    end
  end

  describe "mark_as_paid/1" do
    test "mark :in_process state payment as :paid" do
      {:ok, payment} =
        Payment.new(%{
          payment_code: "pay-123",
          sale_id: "sale-1",
          amount: 50_000
        })

      assert {:ok, paid_payment} = Payment.mark_as_paid(payment)

      assert paid_payment.payment_status == :paid
      assert %DateTime{} = paid_payment.updated_at
    end

    test "returns error when the state is already paid" do
      payment = %Payment{
        id: "p1",
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: 50_000,
        payment_status: :paid,
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_transition} = Payment.mark_as_paid(payment)
    end

    test "returns error when the state is already cancelled" do
      payment = %Payment{
        id: "p1",
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: 50_000,
        payment_status: :cancelled,
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_transition} = Payment.mark_as_paid(payment)
    end
  end

  describe "cancel/1" do
    test "mark :in_process state as :cancel" do
      {:ok, payment} =
        Payment.new(%{
          payment_code: "pay-123",
          sale_id: "sale-1",
          amount: 30_000
        })

      assert {:ok, cancelled_payment} = Payment.cancel(payment)

      assert cancelled_payment.payment_status == :cancelled
      assert %DateTime{} = cancelled_payment.updated_at
    end

    test "returns error to cancel an already :paid payment" do
      payment = %Payment{
        id: "p1",
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: 30_000,
        payment_status: :paid,
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_transition} = Payment.cancel(payment)
    end

    test "returns error to cancel an already :cancelled payment" do
      payment = %Payment{
        id: "p1",
        payment_code: "pay-123",
        sale_id: "sale-1",
        amount: 30_000,
        payment_status: :cancelled,
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_transition} = Payment.cancel(payment)
    end
  end
end
