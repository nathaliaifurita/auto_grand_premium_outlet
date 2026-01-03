defmodule AutoGrandPremiumOutlet.Test.Support.Repositories.VehicleRepoMock do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  defp base_vehicle do
    %Vehicle{
      id: "135",
      brand: "Toyota",
      model: "Corolla",
      year: 2022,
      color: "Preto",
      price: 120_000,
      license_plate: "ABC1D35",
      status: :available,
      inserted_at: DateTime.utc_now(),
      updated_at: nil,
      sold_at: nil
    }
  end

  ## ---------- Commands ----------

  @impl true
  def save(%Vehicle{} = vehicle), do: {:ok, vehicle}

  @impl true
  def update(%Vehicle{} = vehicle) do
    {:ok, %{vehicle | updated_at: DateTime.utc_now()}}
  end

  ## ---------- Queries ----------

  @impl true
  def get("135"), do: {:ok, base_vehicle()}
  def get(_), do: {:error, :not_found}

  @impl true
  def list_sold do
    {:ok,
     [
       %Vehicle{
         id: "v3",
         brand: "Fiat",
         model: "Uno",
         year: 2015,
         color: "red",
         price: 25_000,
         license_plate: "GHI9999",
         status: :sold
       },
       %Vehicle{
         id: "v4",
         brand: "Audi",
         model: "A4",
         year: 2021,
         color: "silver",
         price: 120_000,
         license_plate: "JKL0001",
         status: :sold
       }
     ]}
  end

  @impl true
  def list_available_ordered_by_price do
    {:ok,
     [
       %Vehicle{
         id: "v1",
         brand: "Ford",
         model: "Ka",
         year: 2018,
         color: "white",
         price: 30_000,
         license_plate: "ABC1240",
         status: :available
       },
       %Vehicle{
         id: "v2",
         brand: "BMW",
         model: "320i",
         year: 2020,
         color: "black",
         price: 90_000,
         license_plate: "DEF5678",
         status: :available
       }
     ]}
  end
end
