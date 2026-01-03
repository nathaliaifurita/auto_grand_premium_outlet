defmodule AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  ## -------- GET --------

  @impl true
  def get(_id), do: {:error, :not_found}

  ## -------- LIST --------

  @impl true
  def list_available_ordered_by_price do
    # Repository should return vehicles sorted by price in ascending order
    # This is a data access concern, not a business logic concern
    {:ok, []}
  end

  @impl true
  def list_sold do
    # Repository should return sold vehicles sorted by price in ascending order
    # This is a data access concern, not a business logic concern
    {:ok, []}
  end

  ## -------- CREATE --------

  @impl true
  def save(%Vehicle{} = vehicle) do
    {:ok, vehicle}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Vehicle{} = vehicle) do
    {:ok, vehicle}
  end
end
