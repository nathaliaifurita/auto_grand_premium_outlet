defmodule AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Vehicles.CreateVehicle
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  defmodule VehicleRepoMock do
    alias AutoGrandPremiumOutlet.Domain.Vehicle

    def save(%Vehicle{} = vehicle) do
      {:ok, vehicle}
    end

    def save(%Vehicle{year: year}) when year < 1886 do
      {:error, :invalid_year}
    end

    def save(_), do: {:error, :persistence_error}
  end

  defmodule VehicleRepoErrorMock do
    alias AutoGrandPremiumOutlet.Domain.Vehicle

    def save(%Vehicle{}) do
      {:error, :persistence_error}
    end
  end

  defmodule IdGeneratorMock do
    def generate, do: "test-id-123"
  end

  defmodule ClockMock do
    def now, do: DateTime.utc_now()
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

      assert {:ok, vehicle} =
               CreateVehicle.execute(attrs, VehicleRepoMock, IdGeneratorMock, ClockMock)

      assert vehicle.brand == "Toyota"
      assert vehicle.model == "Corolla"
      assert vehicle.year == 2022
      assert vehicle.status == :available
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
               CreateVehicle.execute(attrs, VehicleRepoMock, IdGeneratorMock, ClockMock)
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
               CreateVehicle.execute(attrs, VehicleRepoMock, IdGeneratorMock, ClockMock)
    end

    test "returns invalid_year when year is invalid" do
      attrs = %{
        brand: "Ford",
        model: "T",
        year: 1800,
        price: 10_000,
        license_plate: "AAA0001"
      }

      assert {:error, :invalid_year} =
               CreateVehicle.execute(attrs, VehicleRepoMock, IdGeneratorMock, ClockMock)
    end

    test "returns persistence_error when repo fails" do
      attrs = %{
        brand: "Honda",
        model: "Civic",
        year: 2020,
        color: "silver",
        price: 90_000,
        license_plate: "ABC1D23"
      }

      assert {:error, :persistence_error} =
               CreateVehicle.execute(attrs, VehicleRepoErrorMock, IdGeneratorMock, ClockMock)
    end

    test "normalizes string parameters from HTTP requests" do
      # Simulating HTTP request with string keys and string values
      attrs = %{
        "brand" => "Toyota",
        "model" => "Corolla",
        "year" => "2022",
        "color" => "black",
        "price" => "120000",
        "license_plate" => "XYZ2A34"
      }

      assert {:ok, vehicle} =
               CreateVehicle.execute(attrs, VehicleRepoMock, IdGeneratorMock, ClockMock)

      assert vehicle.brand == "Toyota"
      assert vehicle.model == "Corolla"
      assert vehicle.year == 2022
      assert vehicle.price == 120_000
      assert vehicle.license_plate == "XYZ2A34"
    end
  end
end
