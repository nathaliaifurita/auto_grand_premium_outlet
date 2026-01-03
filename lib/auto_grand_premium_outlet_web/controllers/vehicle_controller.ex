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

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def index(conn, _params) do
    with {:ok, vehicles} <-
           ListAvailableVehicles.execute(vehicle_repo()) do
      json(conn, VehicleSerializer.serialize_many(vehicles))
    end
  end

  def sold(conn, _params) do
    with {:ok, vehicles} <-
           ListSoldVehicles.execute(vehicle_repo()) do
      json(conn, VehicleSerializer.serialize_many(vehicles))
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, vehicle} <- GetVehicle.execute(id, vehicle_repo()) do
      json(conn, VehicleSerializer.serialize(vehicle))
    end
  end

  def create(conn, params) do
    with {:ok, vehicle} <- CreateVehicle.execute(params, vehicle_repo(), id_generator(), clock()) do
      conn
      |> put_status(:created)
      |> json(VehicleSerializer.serialize(vehicle))
    end
  end

  def update(conn, %{"id" => id} = params) do
    with {:ok, vehicle} <- UpdateVehicle.execute(id, params, vehicle_repo(), clock()) do
      json(conn, VehicleSerializer.serialize(vehicle))
    end
  end
  defp vehicle_repo do
    Application.fetch_env!(
      :auto_grand_premium_outlet,
      :vehicle_repo
    )
  end

  defp id_generator do
    Application.fetch_env!(:auto_grand_premium_outlet, :id_generator)
  end

  defp clock do
    Application.fetch_env!(:auto_grand_premium_outlet, :clock)
  end
end
