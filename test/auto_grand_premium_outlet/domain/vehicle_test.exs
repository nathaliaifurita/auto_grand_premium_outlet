defmodule AutoGrandPremiumOutlet.Domain.VehicleTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  describe "new/1" do
    test "creates a new vehicle with state :available" do
      attrs = %{
        id: "vehicle-123",
        brand: "Toyota",
        model: "Corolla",
        year: 2020,
        color: "Prata",
        price: 85000,
        license_plate: "ABC1D23",
        inserted_at: DateTime.utc_now()
      }

      assert {:ok, vehicle} = Vehicle.new(attrs)

      assert vehicle.brand == "Toyota"
      assert vehicle.model == "Corolla"
      assert vehicle.year == 2020
      assert vehicle.color == "Prata"
      assert vehicle.price == 85000
      assert vehicle.license_plate == "ABC1D23"
      assert vehicle.status == :available, "Status deve ser :available por padrão"
      assert vehicle.inserted_at != nil
      assert vehicle.updated_at == nil
    end

    test "returns error when the year is invalid" do
      attrs = %{
        id: "vehicle-123",
        brand: "Ford",
        model: "Ka",
        year: 1700,
        color: "Azul",
        price: 30000,
        license_plate: "DEF5678Y",
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_year} = Vehicle.new(attrs)
    end

    test "returns error when price is negative" do
      attrs = %{
        id: "vehicle-123",
        brand: "Fiat",
        model: "Uno",
        year: 2015,
        color: "Vermelho",
        price: -10,
        license_plate: "GHI9012Z",
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_price} = Vehicle.new(attrs)
    end

    test "returns error when the license plate is invalid" do
      attrs = %{
        id: "vehicle-123",
        brand: "Renault",
        model: "Sandero",
        year: 2020,
        color: "Branco",
        price: 45_000,
        license_plate: "123ABC",
        inserted_at: DateTime.utc_now()
      }

      assert {:error, :invalid_license_plate} = Vehicle.new(attrs)
    end
  end

  describe "sell/1" do
    test "sells an available vehicle" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Honda",
          model: "Civic",
          year: 2019,
          color: "Azul",
          price: 90000,
          license_plate: "XYZ2A34",
          inserted_at: DateTime.utc_now()
        })

      assert {:ok, sold_vehicle} = Vehicle.sell(vehicle, DateTime.utc_now())
      assert sold_vehicle.status == :sold
    end

    test "returns error when the vehicle has already sold" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Ford",
          model: "Focus",
          year: 2018,
          color: "Cinza",
          price: 75000,
          license_plate: "LMN3B45",
          inserted_at: DateTime.utc_now()
        })

      {:ok, sold_vehicle} = Vehicle.sell(vehicle, DateTime.utc_now())

      assert {:error, :vehicle_already_sold} = Vehicle.sell(sold_vehicle, DateTime.utc_now())
    end
  end

  describe "update/2" do
    test "updates vehicle info and defines updated_at date" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Toyota",
          model: "Corolla",
          year: 2020,
          color: "Prata",
          price: 85000,
          license_plate: "ABC1D23",
          inserted_at: DateTime.utc_now()
        })

      :timer.sleep(1000)

      {:ok, updated_vehicle} =
        Vehicle.update(vehicle, %{
          color: "Preto",
          price: 80000
        }, DateTime.utc_now())

      assert updated_vehicle.color == "Preto"
      assert updated_vehicle.price == 80000
      assert updated_vehicle.updated_at != nil
      assert DateTime.compare(updated_vehicle.updated_at, vehicle.inserted_at) == :gt
    end

    test "updates only some fields" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Honda",
          model: "Civic",
          year: 2019,
          color: "Azul",
          price: 90000,
          license_plate: "XYZ2A34",
          inserted_at: DateTime.utc_now()
        })

      :timer.sleep(1000)

      {:ok, updated_vehicle} =
        Vehicle.update(vehicle, %{
          color: "Vermelho"
        }, DateTime.utc_now())

      assert updated_vehicle.brand == vehicle.brand
      assert updated_vehicle.model == vehicle.model
      assert updated_vehicle.year == vehicle.year
      assert updated_vehicle.price == vehicle.price
      assert updated_vehicle.license_plate == vehicle.license_plate
      assert updated_vehicle.color == "Vermelho"
      assert updated_vehicle.updated_at != nil
    end

    test "does not update updated_at if no field is modified" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Chevrolet",
          model: "Onix",
          year: 2021,
          color: "Branco",
          price: 95000,
          license_plate: "OPQ4C56",
          inserted_at: DateTime.utc_now()
        })

      {:ok, updated_vehicle} = Vehicle.update(vehicle, %{}, DateTime.utc_now())

      assert updated_vehicle.updated_at == nil
    end

    test "successfully updates multiple fields" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Nissan",
          model: "Sentra",
          year: 2017,
          color: "Prata",
          price: 70000,
          license_plate: "RST5D67",
          inserted_at: DateTime.utc_now()
        })

      :timer.sleep(1000)

      {:ok, updated_vehicle} =
        Vehicle.update(vehicle, %{
          brand: "Renault",
          model: "Sandero",
          year: 2018,
          color: "Preto",
          price: 80000
        }, DateTime.utc_now())

      assert updated_vehicle.brand == "Renault"
      assert updated_vehicle.model == "Sandero"
      assert updated_vehicle.year == 2018
      assert updated_vehicle.color == "Preto"
      assert updated_vehicle.price == 80000
      assert updated_vehicle.status == :available
      assert updated_vehicle.updated_at != nil
      assert updated_vehicle.sold_at == nil
      assert updated_vehicle.license_plate == "RST5D67"
    end

    test "não permite atualizar veículo com dados inválidos mantém dados originais" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Volkswagen",
          model: "Golf",
          year: 2016,
          color: "Azul",
          price: 80000,
          license_plate: "UVW6E78",
          inserted_at: DateTime.utc_now()
        })

      :timer.sleep(1000)

      {:error, :invalid_price} =
        Vehicle.update(vehicle, %{
          price: -5000
        }, DateTime.utc_now())

      assert vehicle.price == 80000
      assert vehicle.updated_at == nil
    end

    test "returns error for an invalid year" do
      {:ok, vehicle} =
        Vehicle.new(%{
          id: "vehicle-123",
          brand: "Mazda",
          model: "3",
          year: 2015,
          color: "Vermelho",
          price: 60000,
          license_plate: "XYZ7F89",
          inserted_at: DateTime.utc_now()
        })

      :timer.sleep(1000)

      {:error, :invalid_year} =
        Vehicle.update(vehicle, %{
          year: 1700
        }, DateTime.utc_now())

      assert vehicle.year == 2015
      assert vehicle.updated_at == nil
    end
  end
end
