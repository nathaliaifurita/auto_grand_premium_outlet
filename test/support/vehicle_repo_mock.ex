defmodule AutoGrandPremiumOutlet.Test.Support.Repositories.VehicleRepoMock do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.VehicleRepository

  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Infra.Services.IdGenerator

  # Generate IDs once at compile time for consistency in tests
  @base_vehicle_id IdGenerator.generate()
  @v1_id IdGenerator.generate()
  @v2_id IdGenerator.generate()
  @v3_id IdGenerator.generate()
  @v4_id IdGenerator.generate()

  defp base_vehicle do
    %Vehicle{
      id: @base_vehicle_id,
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

  # Helper function to access the base vehicle ID in tests
  def base_vehicle_id, do: @base_vehicle_id

  ## ---------- Commands ----------

  @impl true
  def save(%Vehicle{} = vehicle), do: {:ok, vehicle}

  @impl true
  def update(%Vehicle{} = vehicle) do
    {:ok, %{vehicle | updated_at: DateTime.utc_now()}}
  end

  ## ---------- Queries ----------

  @impl true
  def get(id) when id == @base_vehicle_id, do: {:ok, base_vehicle()}
  def get(_), do: {:error, :not_found}

  @impl true
  def list_sold do
    {:ok,
     [
       %Vehicle{
         id: @v3_id,
         brand: "Fiat",
         model: "Uno",
         year: 2015,
         color: "red",
         price: 25_000,
         license_plate: "GHI9999",
         status: :sold
       },
       %Vehicle{
         id: @v4_id,
         brand: "Audi",
         model: "A4",
         year: 2021,
         color: "silver",
         price: 120_000,
         license_plate: "JKL0001",
         status: :sold
       },
       %Vehicle{
         id: @v1_id,
         brand: "Ford",
         model: "Ka",
         year: 2018,
         color: "white",
         price: 30_000,
         license_plate: "ABC1240",
         status: :available
       },
       %Vehicle{
         id: @v2_id,
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

  @impl true
  def list_available_ordered_by_price do
    {:ok,
     [
       %Vehicle{
         id: @v1_id,
         brand: "Ford",
         model: "Ka",
         year: 2018,
         color: "white",
         price: 30_000,
         license_plate: "ABC1240",
         status: :available
       },
       %Vehicle{
         id: @v2_id,
         brand: "BMW",
         model: "320i",
         year: 2020,
         color: "black",
         price: 90_000,
         license_plate: "DEF5678",
         status: :available
       },
       %Vehicle{
         id: @v3_id,
         brand: "Fiat",
         model: "Uno",
         year: 2015,
         color: "red",
         price: 25_000,
         license_plate: "GHI9999",
         status: :sold
       },
       %Vehicle{
         id: @v4_id,
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
end
