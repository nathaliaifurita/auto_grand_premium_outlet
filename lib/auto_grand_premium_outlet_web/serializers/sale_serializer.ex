defmodule AutoGrandPremiumOutletWeb.SaleSerializer do
  @moduledoc """
  Serializes Sale domain entities to JSON-friendly maps.
  """

  alias AutoGrandPremiumOutlet.Domain.Sale

  @spec serialize(Sale.t()) :: map()
  def serialize(%Sale{} = sale) do
    %{
      id: sale.id,
      vehicle_id: sale.vehicle_id,
      buyer_cpf: sale.buyer_cpf,
      status: sale.status,
      inserted_at: sale.inserted_at,
      updated_at: sale.updated_at
    }
  end
end
