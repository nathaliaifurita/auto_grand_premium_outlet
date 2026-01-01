defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
  alias AutoGrandPremiumOutlet.Domain.Vehicle

  ## ---- SINGLE ----

  def serialize(%Vehicle{} = vehicle) do
    %{
      id: vehicle.id,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      color: vehicle.color,
      price: vehicle.price,
      license_plate: vehicle.license_plate,
      status: Atom.to_string(vehicle.status),
      sold_at: vehicle.sold_at
    }
  end

  ## ---- MANY ----

  def serialize_many(vehicles) when is_list(vehicles) do
    Enum.map(vehicles, &serialize/1)
  end
end
