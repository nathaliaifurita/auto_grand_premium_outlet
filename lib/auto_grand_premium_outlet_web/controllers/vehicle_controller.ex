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
    with {:ok, vehicle} <- CreateVehicle.execute(params, vehicle_repo()) do
      conn
      |> put_status(:created)
      |> json(VehicleSerializer.serialize(vehicle))
    end
  end

  ### melhoria: normalizar params antes de passar para o use case
  # def create(conn, params) do
  #   with {:ok, vehicle} <- CreateVehicle.execute(params) do
  #     conn
  #     |> put_status(:created)
  #     |> json(VehicleSerializer.serialize(vehicle))
  #   end
  # end

  def update(conn, %{"id" => id} = params) do
    with {:ok, vehicle} <- UpdateVehicle.execute(id, params, vehicle_repo()) do
      json(conn, VehicleSerializer.serialize(vehicle))
    end
  end
  
  ### melhoria: normalizar params antes de passar para o use case
  defp vehicle_repo do
    Application.fetch_env!(:auto_grand_premium_outlet, :vehicle_repo)
  end

  defp normalize_params(params) do
    params
    |> Map.update("year", nil, &parse_int/1)
    |> Map.update("price", nil, &parse_int/1)
  end

  defp parse_int(value) when is_integer(value), do: value

  defp parse_int(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> value
    end
  end

  defp parse_int(value), do: value
end
