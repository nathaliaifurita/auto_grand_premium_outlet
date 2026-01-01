# # defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
# #   alias AutoGrandPremiumOutlet.Domain.Vehicle

# #   def serialize(%Vehicle{} = vehicle) do
# #     %{
# #       id: vehicle.id,
# #       brand: vehicle.brand,
# #       model: vehicle.model,
# #       year: vehicle.year,
# #       color: vehicle.color,
# #       price: vehicle.price,
# #       license_plate: vehicle.license_plate,
# #       status: vehicle.status
# #     }
# #   end

# #   def serialize_many(vehicles) when is_list(vehicles) do
# #     Enum.map(vehicles, &serialize/1)
# #   end
# # # end

# # defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
# #   alias AutoGrandPremiumOutlet.Domain.Vehicle

# #   def serialize(%Vehicle{} = vehicle) do
# #     %{
# #       id: vehicle.id,
# #       brand: vehicle.brand,
# #       model: vehicle.model,
# #       year: vehicle.year,
# #       color: vehicle.color,
# #       price: vehicle.price,
# #       status: vehicle.status
# #     }
# #   end

# #   def serialize_list(vehicles) do
# #     Enum.map(vehicles, &serialize/1)
# #   end
# # end

# # defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
# #   alias AutoGrandPremiumOutlet.Domain.Vehicle

# #   @spec serialize(Vehicle.t()) :: map()
# #   def serialize(%Vehicle{} = vehicle) do
# #     %{
# #       id: vehicle.id,
# #       brand: vehicle.brand,
# #       model: vehicle.model,
# #       year: vehicle.year,
# #       color: vehicle.color,
# #       price: vehicle.price,
# #       license_plate: vehicle.license_plate,
# #       status: serialize_status(vehicle.status),
# #       inserted_at: vehicle.inserted_at,
# #       updated_at: vehicle.updated_at
# #     }
# #   end

# #   @spec serialize_many(list(Vehicle.t())) :: list(map())
# #   def serialize_many(vehicles) when is_list(vehicles) do
# #     Enum.map(vehicles, &serialize/1)
# #   end

# #   ## -------- helpers --------

# #   defp serialize_status(nil), do: nil

# #   defp serialize_status(status) when is_atom(status),
# #     do: Atom.to_string(status)
# # end

# defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   ## ---- PUBLIC API ----

#   def serialize(%Vehicle{} = vehicle) do
#     %{
#       id: vehicle.id,
#       brand: vehicle.brand,
#       model: vehicle.model,
#       year: vehicle.year,
#       color: vehicle.color,
#       price: vehicle.price,
#       license_plate: vehicle.license_plate,
#       status: vehicle.status,
#       sold_at: vehicle.sold_at
#     }
#   end

#   def serialize(vehicles) when is_atom(status) do
#     Atom.to_string(status)
#     Enum.map(vehicles, &serialize/1)
#   end
# end

# defmodule AutoGrandPremiumOutletWeb.VehicleSerializer do
#   alias AutoGrandPremiumOutlet.Domain.Vehicle

#   @spec serialize(Vehicle.t()) :: map()
#   def serialize(%Vehicle{} = vehicle) do
#     %{
#       id: vehicle.id,
#       brand: vehicle.brand,
#       model: vehicle.model,
#       year: vehicle.year,
#       color: vehicle.color,
#       price: vehicle.price,
#       license_plate: vehicle.license_plate,
#       status: Atom.to_string(vehicle.status),
#       sold_at: vehicle.sold_at
#     }
#   end

#   @spec serialize(list(Vehicle.t())) :: list(map())
#   def serialize(vehicles) when is_list(vehicles) do
#     Enum.map(vehicles, &serialize/1)
#   end
# end

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
