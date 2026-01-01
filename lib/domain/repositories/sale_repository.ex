defmodule AutoGrandPremiumOutlet.Domain.Repositories.SaleRepository do
  @moduledoc """
  Repository port for Sale persistence.
  """
  alias AutoGrandPremiumOutlet.Domain.Sale

  @callback create(Sale.t()) :: {:ok, Sale.t()} | {:error, term()}

  @callback get(String.t()) ::
              {:ok, Sale.t()} | {:error, :not_found}

  @callback update(Sale.t()) :: {:ok, Sale.t()} | {:error, term()}
end
