defmodule AutoGrandPremiumOutlet.Infra.Repositories.SaleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.SaleRepository

  alias AutoGrandPremiumOutlet.Domain.Sale

  ## -------- GET --------

  @impl true
  def get(_id), do: {:error, :not_found}

  ## -------- CREATE --------

  @impl true
  def create(%Sale{} = sale) do
    {:ok, sale}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Sale{} = sale) do
    {:ok, sale}
  end
end
