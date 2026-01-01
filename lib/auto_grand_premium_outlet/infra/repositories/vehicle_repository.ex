# defmodule AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo do
#   @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   def save(%Vehicle{} = vehicle) do
#     {:ok, vehicle}
#   end

#   def get(id) do
#     {:error, :not_found}
#   end

#   def list do
#     []
#   end
# end

defmodule AutoGrandPremiumOutlet.Infra.Repositories.VehicleRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  ## -------- GET --------

  @impl true
  def get(_id), do: {:error, :not_found}

  ## -------- LIST --------

  @impl true
  def list_available_ordered_by_price do
    {:ok, []}
  end

  @impl true
  def list_sold do
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
