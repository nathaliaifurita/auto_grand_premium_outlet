# defmodule AutoGrandPremiumOutlet.UseCases.Sales.CompleteSale do
#   @moduledoc """
#   Completes a sale and marks the vehicle as sold.
#   """

#   alias AutoGrandPremiumOutlet.Domain.{Sale, Vehicle}
#   alias AutoGrandPremiumOutlet.Domain.Repositories.{SaleRepository, VehicleRepository}

#   @type error ::
#           :sale_not_found
#           | :invalid_sale_state
#           | :vehicle_already_sold
#           | :persistence_error

#   @spec execute(String.t(), SaleRepository.t(), VehicleRepository.t()) ::
#           {:ok, Sale.t()} | {:error, error()}

#   def execute(sale_id, sale_repo, vehicle_repo) do
#     with {:ok, sale} <- sale_repo.get(sale_id),
#          :ok <- ensure_in_initiated(sale),
#          {:ok, vehicle} <-
#            vehicle_repo.get(sale.vehicle_id),
#          {:ok, _vehicle} <- Vehicle.sell(vehicle),
#          {:ok, completed_sale} <- Sale.complete(sale),
#          {:ok, saved_sale} <- sale_repo.update(completed_sale) do
#       {:ok, saved_sale}
#     else
#       {:error, :not_found} ->
#         {:error, :sale_not_found}

#       {:error, :not_found} ->
#         {:error, :vehicle_not_found}

#       {:error, :vehicle_already_sold} ->
#         {:error, :vehicle_already_sold}

#       {:error, :invalid_sale_state} ->
#         {:error, :invalid_sale_state}

#       {:error, :invalid_transition} ->
#         {:error, :invalid_sale_state}

#       {:error, :invalid_state} ->
#         {:error, :invalid_sale_state}

#       _ ->
#         {:error, :persistence_error}
#     end
#   end

#   defp ensure_in_initiated(%Sale{status: :initiated}), do: :ok
#   defp ensure_in_initiated(_), do: {:error, :invalid_sale_state}
# end

defmodule AutoGrandPremiumOutlet.UseCases.Sales.CompleteSale do
  @moduledoc """
  Completes a sale and marks the vehicle as sold.
  """

  alias AutoGrandPremiumOutlet.Domain.{Sale, Vehicle}

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    SaleRepository,
    VehicleRepository
  }

  @type error ::
          :sale_not_found
          | :vehicle_not_found
          | :invalid_sale_state
          | :vehicle_already_sold
          | :persistence_error

  @spec execute(String.t(), SaleRepository.t(), VehicleRepository.t()) ::
          {:ok, Sale.t()} | {:error, error()}

  def execute(sale_id, sale_repo, vehicle_repo) do
    with {:ok, sale} <- get_sale(sale_repo, sale_id),
         :ok <- ensure_in_initiated(sale),
         {:ok, vehicle} <- get_vehicle(vehicle_repo, sale.vehicle_id),
         {:ok, _vehicle} <- Vehicle.sell(vehicle),
         {:ok, completed_sale} <- Sale.complete(sale),
         {:ok, saved_sale} <- sale_repo.update(completed_sale) do
      {:ok, saved_sale}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  ## -------- Private helpers --------

  defp get_sale(repo, sale_id) do
    case repo.get(sale_id) do
      {:ok, sale} -> {:ok, sale}
      {:error, :not_found} -> {:error, :sale_not_found}
      _ -> {:error, :persistence_error}
    end
  end

  defp get_vehicle(repo, vehicle_id) do
    case repo.get(vehicle_id) do
      {:ok, vehicle} -> {:ok, vehicle}
      {:error, :not_found} -> {:error, :vehicle_not_found}
      _ -> {:error, :persistence_error}
    end
  end

  defp ensure_in_initiated(%Sale{status: :initiated}), do: :ok
  defp ensure_in_initiated(_), do: {:error, :invalid_sale_state}
end
