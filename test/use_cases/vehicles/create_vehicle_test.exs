# defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicleTest do
#   use ExUnit.Case, async: true

#   alias AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicle
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   describe "execute/1" do
#     test "creates a vehicle with valid attributes" do
#       attrs = %{
#         brand: "Toyota",
#         model: "Corolla",
#         year: 2022,
#         color: "black",
#         price: 120_000,
#         license_plate: "XYZ2A34"
#       }

#       assert {:ok, %Vehicle{} = vehicle} = CreateVehicle.execute(attrs, %Vehicle{})

#       assert vehicle.brand == "Toyota"
#       assert vehicle.model == "Corolla"
#       assert vehicle.year == 2022
#       assert vehicle.color == "black"
#       assert vehicle.price == 120_000
#       assert vehicle.license_plate == "XYZ2A34"
#       assert vehicle.status == :available
#       assert vehicle.inserted_at != nil
#       assert vehicle.updated_at == nil
#     end

#     test "returns error when year is invalid" do
#       attrs = %{
#         brand: "Ford",
#         model: "Ka",
#         year: 1700,
#         price: 30_000,
#         license_plate: "LMN3B45"
#       }

#       assert {:error, :invalid_year} = CreateVehicle.execute(attrs)
#     end

#     test "returns error when price is invalid" do
#       attrs = %{
#         brand: "Fiat",
#         model: "Uno",
#         year: 2010,
#         price: -100,
#         license_plate: "OPQ4C56"
#       }

#       assert {:error, :invalid_price} = CreateVehicle.execute(attrs)
#     end
#   end
# end

defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicle
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  ## -------- Repo Mock --------

  defmodule VehicleRepoMock do
    def create(%Vehicle{} = vehicle) do
      {:ok, %{vehicle | id: "1"}}
    end
  end

  describe "execute/2" do
    test "creates a vehicle with valid attributes" do
      attrs = %{
        brand: "Toyota",
        model: "Corolla",
        year: 2022,
        color: "black",
        price: 120_000,
        license_plate: "XYZ2A34"
      }

      assert {:ok, %Vehicle{} = vehicle} =
               CreateVehicle.execute(attrs, VehicleRepoMock)

      assert vehicle.id == "1"
      assert vehicle.brand == "Toyota"
      assert vehicle.model == "Corolla"
      assert vehicle.year == 2022
      assert vehicle.color == "black"
      assert vehicle.price == 120_000
      assert vehicle.license_plate == "XYZ2A34"
      assert vehicle.status == :available
      assert vehicle.inserted_at != nil
      assert vehicle.updated_at == nil
    end

    test "returns error when year is invalid" do
      attrs = %{
        brand: "Ford",
        model: "Ka",
        year: 1700,
        price: 30_000,
        license_plate: "LMN3B45"
      }

      assert {:error, :invalid_year} =
               CreateVehicle.execute(attrs, VehicleRepoMock)
    end

    test "returns error when price is invalid" do
      attrs = %{
        brand: "Fiat",
        model: "Uno",
        year: 2010,
        price: -100,
        license_plate: "OPQ4C56"
      }

      assert {:error, :invalid_price} =
               CreateVehicle.execute(attrs, VehicleRepoMock)
    end

    test "returns persistence_error when repo fails" do
      defmodule VehicleRepoErrorMock do
        def create(_vehicle), do: {:error, :db_error}
      end

      attrs = %{
        brand: "Honda",
        model: "Civic",
        year: 2020,
        color: "silver",
        price: 90_000,
        license_plate: "ABC1D23"
      }

      assert {:error, :persistence_error} =
               CreateVehicle.execute(attrs, VehicleRepoErrorMock)
    end
  end
end
