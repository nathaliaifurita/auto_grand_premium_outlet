defmodule AutoGrandPremiumOutlet.Domain.SaleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.Domain.Sale

  describe "new/1" do
    test "returns a valid sale with default :initiated state" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: "12345678901"
      }

      assert {:ok, %Sale{} = sale} = Sale.new(attrs)

      assert sale.vehicle_id == "vehicle-123"
      assert sale.buyer_cpf == "12345678901"
      assert sale.status == :initiated
      assert %DateTime{} = sale.inserted_at
      assert sale.updated_at == nil
    end

    test "does not allow to create a new sale with :completed state" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: "12345678901",
        status: :completed
      }

      assert {:error, :invalid_state} = Sale.new(attrs)
    end

    test "does not allow to create a new sale with :cancelled state" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: "12345678901",
        status: :cancelled
      }

      assert {:error, :invalid_state} = Sale.new(attrs)
    end

    test "returns error when CPF is invalid" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: "123"
      }

      assert {:error, :invalid_cpf} = Sale.new(attrs)
    end

    test "returns error when CPF has letters" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: "123ABC78901"
      }

      assert {:error, :invalid_cpf} = Sale.new(attrs)
    end

    test "returns error when CPF is not a string" do
      attrs = %{
        vehicle_id: "vehicle-123",
        buyer_cpf: 12_345_678_901
      }

      assert {:error, :invalid_cpf} = Sale.new(attrs)
    end
  end

  @now DateTime.utc_now()

  defp build_sale(attrs) do
    %Sale{
      id: Map.get(attrs, :id, "sale-1"),
      vehicle_id: Map.get(attrs, :vehicle_id, "vehicle-1"),
      buyer_cpf: Map.get(attrs, :buyer_cpf, "12345678901"),
      status: Map.get(attrs, :status, :initiated),
      inserted_at: Map.get(attrs, :inserted_at, @now),
      updated_at: Map.get(attrs, :updated_at, nil)
    }
  end

  ## -------- Tests for complete/1 --------

  test "completes a sale in initiated state" do
    sale = build_sale(%{status: :initiated})

    assert {:ok, completed_sale} = Sale.complete(sale)
    assert completed_sale.status == :completed
    refute is_nil(completed_sale.updated_at)
  end

  test "cannot complete a sale in cancelled state" do
    sale = build_sale(%{status: :cancelled})
    assert {:error, :invalid_transition} = Sale.complete(sale)
  end

  test "cannot complete a sale in completed state" do
    sale = build_sale(%{status: :completed})
    assert {:error, :invalid_transition} = Sale.complete(sale)
  end

  ## -------- Tests for cancel/1 --------

  test "cancels a sale in initiated state" do
    sale = build_sale(%{status: :initiated})

    assert {:ok, cancelled_sale} = Sale.cancel(sale)
    assert cancelled_sale.status == :cancelled
    refute is_nil(cancelled_sale.updated_at)
  end

  test "cannot cancel a sale in completed state" do
    sale = build_sale(%{status: :completed})
    assert {:error, :invalid_transition} = Sale.cancel(sale)
  end

  test "cannot cancel a sale already cancelled" do
    sale = build_sale(%{status: :cancelled})
    assert {:error, :invalid_transition} = Sale.cancel(sale)
  end
end
