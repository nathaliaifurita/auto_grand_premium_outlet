defmodule AutoGrandPremiumOutletWeb.VehicleController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Vehicles.{
    CreateVehicle,
    UpdateVehicle,
    ListAvailableVehicles,
    ListSoldVehicles,
    GetVehicle
  }

  alias AutoGrandPremiumOutletWeb.VehicleSerializer
  alias AutoGrandPremiumOutletWeb.BaseController

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def index(conn, _params) do
    with {:ok, vehicles} <-
           ListAvailableVehicles.execute(BaseController.vehicle_repo()) do
      json(conn, VehicleSerializer.serialize_many(vehicles))
    end
  end

  def sold(conn, _params) do
    with {:ok, vehicles} <-
           ListSoldVehicles.execute(BaseController.vehicle_repo()) do
      json(conn, VehicleSerializer.serialize_many(vehicles))
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, vehicle} <- GetVehicle.execute(id, BaseController.vehicle_repo()) do
      json(conn, VehicleSerializer.serialize(vehicle))
    end
  end

  def create(conn, params) do
    with {:ok, vehicle} <-
           CreateVehicle.execute(
             params,
             BaseController.vehicle_repo(),
             BaseController.id_generator(),
             BaseController.clock()
           ) do
      conn
      |> put_status(:created)
      |> json(VehicleSerializer.serialize(vehicle))
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, vehicle} <-
           UpdateVehicle.execute(id, params, BaseController.vehicle_repo(), BaseController.clock()) do
      json(conn, VehicleSerializer.serialize(vehicle))
    end
  end
end
