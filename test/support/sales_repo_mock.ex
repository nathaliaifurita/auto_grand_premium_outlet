defmodule AutoGrandPremiumOutlet.Support.Repositories.SaleRepoMock do
  alias AutoGrandPremiumOutlet.Domain.Sale

  def get("sale-1") do
    {:ok,
     %Sale{
       id: "sale-1",
       vehicle_id: "vehicle-1",
       buyer_cpf: "12345678901",
       status: :initiated,
       inserted_at: DateTime.utc_now(),
       updated_at: nil
     }}
  end

  def get("sale-2") do
    {:ok,
     %Sale{
       id: "sale-2",
       vehicle_id: "vehicle-2",
       buyer_cpf: "12345678901",
       status: :initiated,
       inserted_at: DateTime.utc_now(),
       updated_at: nil
     }}
  end

  def update(%Sale{} = sale) do
    {:ok, %{sale | updated_at: DateTime.utc_now()}}
  end
end
