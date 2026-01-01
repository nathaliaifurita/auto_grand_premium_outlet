defmodule AutoGrandPremiumOutlet.Support.Repositories.PaymentRepoMock do
  alias AutoGrandPremiumOutlet.Domain.Payment

  def save(%Payment{} = payment), do: {:ok, payment}

  def get_by_payment_code("PAY123") do
    {:ok,
     %Payment{
       id: "p1",
       payment_code: "PAY123",
       sale_id: "sale-1",
       amount: 70_000,
       payment_status: :in_process,
       inserted_at: DateTime.utc_now(),
       updated_at: nil
     }}
  end

  def get_by_payment_code("PAY456") do
    {:ok,
     %Payment{
       id: "p2",
       payment_code: "PAY456",
       sale_id: "sale-2",
       amount: 70_000,
       payment_status: :in_process,
       inserted_at: DateTime.utc_now(),
       updated_at: nil
     }}
  end

  def get_by_payment_code(_), do: {:error, :not_found}

  def update(%Payment{} = payment), do: {:ok, payment}
  def update(_), do: {:error, :persistence_error}
end
