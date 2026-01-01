defmodule AutoGrandPremiumOutlet.UseCases.Sales.CreateSale do
  @moduledoc """
  Starts a sale for a vehicle.
  """

  alias AutoGrandPremiumOutlet.Domain.{Sale, Vehicle}

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    SaleRepository,
    VehicleRepository
  }

  @type error ::
          :vehicle_not_found
          | :vehicle_already_sold
          | :invalid_cpf
          | :persistence_error

  @spec execute(
          String.t(),
          String.t(),
          VehicleRepository.t(),
          SaleRepository.t()
        ) :: {:ok, Sale.t()} | {:error, error()}
  def execute(vehicle_id, buyer_cpf, vehicle_repo, sale_repo) do
    with {:ok, vehicle} <- fetch_vehicle(vehicle_id, vehicle_repo),
         :ok <- ensure_available(vehicle),
         {:ok, sale} <- Sale.new(%{vehicle_id: vehicle.id, buyer_cpf: buyer_cpf}),
         {:ok, sale} <- sale_repo.create(sale) do
      {:ok, sale}
    else
      {:error, :not_found} -> {:error, :vehicle_not_found}
      {:error, :vehicle_already_sold} -> {:error, :vehicle_already_sold}
      {:error, :invalid_cpf} -> {:error, :invalid_cpf}
      _ -> {:error, :persistence_error}
    end
  end

  ## -------- helpers --------

  defp fetch_vehicle(id, repo) do
    case repo.get(id) do
      {:ok, vehicle} -> {:ok, vehicle}
      {:error, :not_found} -> {:error, :not_found}
    end
  end

  defp ensure_available(%Vehicle{status: :sold}),
    do: {:error, :vehicle_already_sold}

  defp ensure_available(_),
    do: :ok
end
