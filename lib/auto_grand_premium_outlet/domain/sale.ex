defmodule AutoGrandPremiumOutlet.Domain.Sale do
  @moduledoc """
  Domain entity representing a vehicle sale.
  """

  @enforce_keys [:vehicle_id, :buyer_cpf, :inserted_at]

  defstruct [
    :id,
    :vehicle_id,
    :buyer_cpf,
    :inserted_at,
    :updated_at,
    # :initiated | :completed | :cancelled
    status: :initiated
  ]

  @type status :: :initiated | :completed | :cancelled
  @type t :: %__MODULE__{
          id: any() | nil,
          vehicle_id: String.t(),
          buyer_cpf: String.t(),
          status: status(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t() | nil
        }

  ## -------- constructors --------

  @spec new(map()) ::
          {:ok, t()}
          | {:error, :invalid_state | :invalid_cpf}

  def new(%{status: _}), do: {:error, :invalid_state}

  def new(%{vehicle_id: vehicle_id, buyer_cpf: buyer_cpf} = attrs) do
    with :ok <- validate_vehicle_id(vehicle_id),
         :ok <- validate_cpf(buyer_cpf) do
      {:ok,
       %__MODULE__{
         id: Map.get(attrs, :id, generate_id()),
         vehicle_id: vehicle_id,
         buyer_cpf: buyer_cpf,
         inserted_at: Map.get(attrs, :inserted_at, DateTime.utc_now())
       }}
    end
  end

  ## -------- state transitions --------

  @spec complete(t()) :: {:ok, t()} | {:error, :invalid_transition}
  def complete(%__MODULE__{status: :initiated} = sale) do
    {:ok,
     %{
       sale
       | status: :completed,
         updated_at: DateTime.utc_now()
     }}
  end

  def complete(%__MODULE__{status: status}) when status in [:completed, :cancelled],
    do: {:error, :invalid_transition}

  def complete(%__MODULE__{id: id}) when is_nil(id),
    do: {:error, :sale_not_found}

  @spec cancel(t()) :: {:ok, t()} | {:error, :invalid_transition}
  def cancel(%__MODULE__{status: :initiated} = sale) do
    {:ok,
     %{
       sale
       | status: :cancelled,
         updated_at: DateTime.utc_now()
     }}
  end

  def cancel(%__MODULE__{status: status}) when status in [:completed, :cancelled],
    do: {:error, :invalid_transition}

  def cancel(%__MODULE__{id: id}) when is_nil(id),
    do: {:error, :sale_not_found}

  ## -------- validations --------
  defp generate_id do
    Ecto.UUID.generate()
  end

  defp validate_vehicle_id(id) when is_binary(id) and byte_size(id) > 0, do: :ok
  defp validate_vehicle_id(_), do: {:error, :vehicle_not_found}

  defp validate_cpf(cpf) when is_binary(cpf) do
    if Regex.match?(~r/^\d{11}$/, cpf), do: :ok, else: {:error, :invalid_cpf}
  end

  defp validate_cpf(_), do: {:error, :invalid_cpf}
end
