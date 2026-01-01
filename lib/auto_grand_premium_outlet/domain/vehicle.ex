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
end
