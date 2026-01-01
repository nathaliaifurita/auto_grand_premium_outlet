defmodule AutoGrandPremiumOutlet.UseCases.Sales.CancelSale do
  @moduledoc """
  Cancels a sale if it's still in a cancellable state.
  """

  alias AutoGrandPremiumOutlet.Domain.Sale
  alias AutoGrandPremiumOutlet.Domain.Repositories.SaleRepository

  @type error ::
          :sale_not_found
          | :invalid_sale_state
          | :persistence_error

  ## -------- Public API --------

  @spec execute(String.t(), SaleRepository.t()) ::
          {:ok, Sale.t()} | {:error, error()}
  def execute(sale_id, sale_repo) do
    execute(sale_id, sale_repo, DateTime)
  end

  ## -------- Internal (testable / extensível) --------

  @spec execute(String.t(), SaleRepository.t(), module()) ::
          {:ok, Sale.t()} | {:error, error()}
  def execute(sale_id, sale_repo, _datetime_mod) do
    with {:ok, sale} <- sale_repo.get(sale_id),
         :ok <- ensure_cancellable(sale),
         {:ok, cancelled_sale} <- Sale.cancel(sale),
         {:ok, saved_sale} <- sale_repo.update(cancelled_sale) do
      {:ok, saved_sale}
    else
      {:error, :not_found} ->
        {:error, :sale_not_found}

      {:error, :invalid_sale_state} ->
        {:error, :invalid_sale_state}

      {:error, :invalid_transition} ->
        {:error, :invalid_sale_state}

      {:error, :invalid_state} ->
        {:error, :invalid_sale_state}

      _ ->
        {:error, :persistence_error}
    end
  end

  ## -------- Helpers --------

  defp ensure_cancellable(%Sale{status: status})
       when status in [:initiated],
       do: :ok

  defp ensure_cancellable(_),
    do: {:error, :invalid_sale_state}
end
