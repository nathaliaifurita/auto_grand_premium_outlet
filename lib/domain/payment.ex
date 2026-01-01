defmodule AutoGrandPremiumOutlet.Domain.Payment do
  @moduledoc """
  Domain entity representing a payment for a sale.
  """

  @enforce_keys [:payment_code, :amount, :sale_id, :inserted_at]

  defstruct [
    :id,
    :payment_code,
    :amount,
    :sale_id,
    :inserted_at,
    :updated_at,
    # defaults ALWAYS last
    payment_status: :in_process
  ]

  @type payment_status :: :paid | :cancelled | :in_process
  @type t :: %__MODULE__{
          id: String.t(),
          payment_code: String.t(),
          amount: number(),
          sale_id: String.t(),
          payment_status: payment_status(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t() | nil
        }

  ## -------- constructors --------

  def new(attrs) do
    with :ok <- validate_sale_id(attrs.sale_id),
         :ok <- validate_amount(attrs.amount) do
      {:ok,
       %__MODULE__{
         id: Map.get(attrs, :id, generate_id()),
         payment_code: generate_payment_code(),
         amount: attrs.amount,
         sale_id: attrs.sale_id,
         inserted_at: Map.get(attrs, :inserted_at, DateTime.utc_now())
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  ## -------- state transitions --------

  def mark_as_paid(%__MODULE__{payment_status: :in_process} = payment) do
    {:ok, %{payment | payment_status: :paid, updated_at: DateTime.utc_now()}}
  end

  def mark_as_paid(_),
    do: {:error, :invalid_transition}

  def cancel(%__MODULE__{payment_status: :in_process} = payment) do
    {:ok, %{payment | payment_status: :cancelled, updated_at: DateTime.utc_now()}}
  end

  def cancel(_),
    do: {:error, :invalid_transition}

  ## -------- validations --------

  defp validate_payment_code(code)
       when is_binary(code) and byte_size(code) > 0,
       do: :ok

  defp validate_amount(amount)
       when is_number(amount) and amount > 0,
       do: :ok

  defp validate_amount(_),
    do: {:error, :invalid_amount}

  defp validate_sale_id(sale_id)
       when is_binary(sale_id) and byte_size(sale_id) > 0,
       do: :ok

  defp validate_sale_id(_),
    do: {:error, :invalid_sale_id}

  ## -------- helpers --------

  defp generate_id, do: Ecto.UUID.generate()

  defp generate_payment_code do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16()
  end
end
