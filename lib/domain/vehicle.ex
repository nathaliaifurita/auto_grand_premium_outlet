# defmodule AutoGrandPremiumOutlet.Domain.Vehicle do
#   @moduledoc """
#   Domain entity representing a vehicle.
#   """
#   @enforce_keys [:brand, :model, :year, :price, :color, :license_plate]
#   defstruct [
#     :id,
#     :brand,
#     :model,
#     :year,
#     :color,
#     :price,
#     :license_plate,
#     # :available | :sold
#     :status,
#     :inserted_at,
#     ### when any info from vehicle is updated
#     :updated_at,
#     ### come from sales
#     :sold_at
#   ]

#   @type status :: :available | :sold
#   @type t :: %__MODULE__{}
#   # -------- private helpers --------
#   defp generate_id do
#     Ecto.UUID.generate()
#   end

#   def new(attrs) do
#     with :ok <- validate_year(attrs.year),
#          :ok <- validate_price(attrs.price),
#          :ok <- validate_license_plate(attrs.license_plate) do
#       {:ok,
#        %__MODULE__{
#          id: Map.get(attrs, :id, generate_id()),
#          brand: attrs.brand,
#          model: attrs.model,
#          year: integer(),
#          color: attrs.color,
#          price: attrs.price,
#          license_plate: attrs.license_plate,
#          status: attrs[:status] || :available,
#          inserted_at: attrs[:inserted_at] || DateTime.utc_now(),
#          updated_at: attrs[:updated_at] || nil,
#          sold_at: attrs[:sold_at] || nil
#        }}
#     end
#   end

#   #### regra de negócio para vender o veículo
#   @spec sell(t()) :: {:ok, t()} | {:error, :vehicle_already_sold}
#   def sell(%__MODULE__{status: :sold}),
#     do: {:error, :vehicle_already_sold}

#   def sell(%__MODULE__{} = vehicle) do
#     {:ok,
#      %{
#        vehicle
#        | status: :sold,
#          sold_at: DateTime.utc_now()
#      }}
#   end

#   def update_info(%__MODULE__{} = vehicle, attrs) do
#     # validações
#     with :ok <- maybe_validate_year(attrs[:year]),
#          :ok <- maybe_validate_price(attrs[:price]),
#          :ok <- maybe_validate_license_plate(attrs[:license_plate]) do
#       updated_vehicle =
#         attrs
#         |> Enum.reduce(vehicle, fn
#           {:year, value}, acc -> %{acc | year: value}
#           {:brand, value}, acc -> %{acc | brand: value}
#           {:model, value}, acc -> %{acc | model: value}
#           {:color, value}, acc -> %{acc | color: value}
#           {:price, value}, acc -> %{acc | price: value}
#           {:license_plate, value}, acc -> %{acc | license_plate: value}
#           _, acc -> acc
#         end)

#       updated_vehicle =
#         if updated_vehicle == vehicle do
#           vehicle
#         else
#           %{updated_vehicle | updated_at: DateTime.utc_now()}
#         end

#       {:ok, updated_vehicle}
#     end
#   end

#   ## -------- validations --------

#   defp validate_year(year) when is_integer(year) and year >= 1886, do: :ok
#   defp validate_year(_), do: {:error, :invalid_year}

#   defp validate_price(price) when is_number(price) and price > 0, do: :ok
#   defp validate_price(_), do: {:error, :invalid_price}

#   defp validate_license_plate(license_plate) when is_binary(license_plate) do
#     if Regex.match?(~r/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/, license_plate) do
#       :ok
#     else
#       {:error, :invalid_license_plate}
#     end
#   end

#   defp maybe_validate_year(nil), do: :ok
#   defp maybe_validate_year(year) when is_integer(year) and year >= 1886, do: :ok
#   defp maybe_validate_year(_), do: {:error, :invalid_year}

#   defp maybe_validate_price(nil), do: :ok
#   defp maybe_validate_price(price) when is_number(price) and price > 0, do: :ok
#   defp maybe_validate_price(_), do: {:error, :invalid_price}

#   defp maybe_validate_license_plate(nil), do: :ok

#   defp maybe_validate_license_plate(lp) when is_binary(lp) do
#     if Regex.match?(~r/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/, lp),
#       do: :ok,
#       else: {:error, :invalid_license_plate}
#   end

#   defp maybe_validate_license_plate(_), do: {:error, :invalid_license_plate}
# end

defmodule AutoGrandPremiumOutlet.Domain.Vehicle do
  @moduledoc """
  Domain entity representing a vehicle.
  """

  @enforce_keys [:id, :brand, :model, :year, :price, :license_plate]

  defstruct [
    :id,
    :brand,
    :model,
    :year,
    :color,
    :price,
    :license_plate,
    :status,
    :inserted_at,
    :updated_at,
    :sold_at
  ]

  @type t :: %__MODULE__{
          id: any() | nil,
          brand: String.t(),
          model: String.t(),
          year: integer(),
          color: String.t() | nil,
          price: number(),
          license_plate: String.t(),
          status: atom() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          sold_at: DateTime.t() | nil
        }

  @spec new(map()) ::
          {:ok, t()}
          | {:error, :invalid_year | :invalid_price | :invalid_license_plate}

  def new(attrs) when is_map(attrs) do
    attrs =
      for {k, v} <- attrs, into: %{} do
        key =
          case k do
            k when is_binary(k) -> String.to_existing_atom(k)
            k -> k
          end

        value =
          case key do
            :year when is_binary(v) ->
              String.to_integer(v)

            :price when is_binary(v) ->
              String.to_integer(v)

            _ ->
              v
          end

        {key, value}
      end

    id = Map.get(attrs, :id, generate_id())

    with :ok <- maybe_validate_year(attrs[:year]),
         :ok <- maybe_validate_price(attrs[:price]),
         :ok <- maybe_validate_license_plate(attrs[:license_plate]) do
      {:ok,
       %__MODULE__{
         id: id,
         brand: attrs[:brand],
         model: attrs[:model],
         year: attrs[:year],
         color: attrs[:color],
         price: attrs[:price],
         license_plate: attrs[:license_plate],
         status: Map.get(attrs, :status, :available),
         inserted_at: Map.get(attrs, :inserted_at, DateTime.utc_now()),
         updated_at: nil,
         sold_at: nil
       }}
    end
  end

  def new(_), do: {:error, :persistence_error}

  ## -------- helpers --------

  defp get(map, key, default \\ nil) do
    Map.get(map, key) || Map.get(map, to_string(key)) || default
  end

  @spec available?(t()) :: boolean()
  def available?(%__MODULE__{status: :sold}), do: false
  def available?(_), do: true

  @spec sell(t()) :: {:ok, t()} | {:error, :vehicle_already_sold}
  def sell(%__MODULE__{status: :sold}),
    do: {:error, :vehicle_already_sold}

  def sell(%__MODULE__{} = vehicle) do
    {:ok,
     %{
       vehicle
       | status: :sold,
         sold_at: DateTime.utc_now()
     }}
  end

  def update(%__MODULE__{} = vehicle, attrs) do
    attrs =
      for {k, v} <- attrs, into: %{} do
        key =
          case k do
            k when is_binary(k) -> String.to_existing_atom(k)
            k -> k
          end

        {key, v}
      end

    with :ok <- maybe_validate_year(attrs[:year]),
         :ok <- maybe_validate_price(attrs[:price]),
         :ok <- maybe_validate_license_plate(attrs[:license_plate]) do
      updated_vehicle =
        Enum.reduce(attrs, vehicle, fn
          {:year, value}, acc -> %{acc | year: value}
          {:brand, value}, acc -> %{acc | brand: value}
          {:model, value}, acc -> %{acc | model: value}
          {:color, value}, acc -> %{acc | color: value}
          {:price, value}, acc -> %{acc | price: value}
          {:license_plate, value}, acc -> %{acc | license_plate: value}
          _, acc -> acc
        end)

      updated_vehicle =
        if updated_vehicle == vehicle do
          vehicle
        else
          %{updated_vehicle | updated_at: DateTime.utc_now()}
        end

      {:ok, updated_vehicle}
    end
  end

  ## -------- validations --------
  defp generate_id do
    Ecto.UUID.generate()
  end

  defp validate_license_plate(_), do: {:error, :invalid_license_plate}

  defp maybe_validate_year(nil), do: :ok
  defp maybe_validate_year(year) when is_integer(year) and year >= 1886, do: :ok
  defp maybe_validate_year(_), do: {:error, :invalid_year}

  defp maybe_validate_price(nil), do: :ok
  defp maybe_validate_price(price) when is_number(price) and price > 0, do: :ok
  defp maybe_validate_price(_), do: {:error, :invalid_price}

  defp maybe_validate_license_plate(nil), do: :ok

  defp maybe_validate_license_plate(lp) when is_binary(lp) do
    if Regex.match?(~r/^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/, lp),
      do: :ok,
      else: {:error, :invalid_license_plate}
  end

  defp maybe_validate_license_plate(_), do: {:error, :invalid_license_plate}

  defp cast_value(:year, year) when is_binary(year) do
    case Integer.parse(year) do
      {int, _} -> int
      _ -> year
    end
  end

  defp cast_value(:price, price) when is_binary(price) do
    case Integer.parse(price) do
      {int, _} -> int
      _ -> price
    end
  end

  defp cast_value(_, value), do: value
end
