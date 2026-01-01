defmodule AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  def save(%Vehicle{} = vehicle) do
    {:ok, vehicle}
  end

  def get(id) do
    {:error, :not_found}
  end

  def list do
    []
  end
end
