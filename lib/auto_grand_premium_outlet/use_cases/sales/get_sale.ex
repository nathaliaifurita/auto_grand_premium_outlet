defmodule AutoGrandPremiumOutlet.UseCases.Sales.GetSale do
  @moduledoc """
  Use case to retrieve a sale by id.
  """

  alias AutoGrandPremiumOutlet.Domain.Sale
  alias AutoGrandPremiumOutlet.Domain.Repositories.SaleRepository

  @type error ::
          :sale_not_found

  @spec execute(
          String.t(),
          SaleRepository.t()
        ) :: {:ok, Sale.t()} | {:error, error()}
  def execute(id, sale_repo) do
    case sale_repo.get(id) do
      {:ok, %Sale{} = sale} ->
        {:ok, sale}

      {:error, :not_found} ->
        {:error, :sale_not_found}

      {:error, :sale_not_found} ->
        {:error, :sale_not_found}
    end
  end
end
