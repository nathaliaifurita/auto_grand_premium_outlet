defmodule AutoGrandPremiumOutlet.UseCases.Payments.CreatePayment do
  @moduledoc """
  Use case responsible for creating a payment for a sale.
  """

  alias AutoGrandPremiumOutlet.Domain.Payment

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    PaymentRepository,
    SaleRepository
  }

  @type error ::
          :invalid_amount
          | :sale_not_found
          | :sale_already_completed
          | :sale_already_cancelled
          | :invalid_sale_state
          | :persistence_error

  @spec execute(
          map(),
          PaymentRepository.t(),
          SaleRepository.t()
        ) :: {:ok, Payment.t()} | {:error, error()}
  def execute(params, payment_repo, sale_repo) do
    params =
      for {k, v} <- params, into: %{} do
        key =
          case k do
            k when is_binary(k) -> String.to_existing_atom(k)
            k -> k
          end

        {key, v}
      end

    sale_id = Map.get(params, :sale_id) || Map.get(params, "sale_id")
    amount = Map.get(params, :amount) || Map.get(params, "amount")

    payment_code =
      Map.get(params, :payment_code) || Map.get(params, "payment_code")

    with {:ok, sale} <- fetch_sale(params.sale_id, sale_repo),
         :ok <- ensure_sale_allows_payment(sale),
         {:ok, payment} <-
           Payment.new(%{
             sale_id: sale_id,
             amount: amount,
             payment_code: payment_code
           }),
         {:ok, payment} <- payment_repo.save(payment) do
      {:ok, payment}
    else
      {:error, :sale_not_found} ->
        {:error, :sale_not_found}

      {:error, :invalid_amount} ->
        {:error, :invalid_amount}

      {:error, _} ->
        {:error, :persistence_error}
    end
  end

  ## -------- helpers --------

  defp fetch_sale(sale_id, sale_repo) do
    case sale_repo.get(sale_id) do
      {:ok, sale} -> {:ok, sale}
      {:error, :not_found} -> {:error, :sale_not_found}
    end
  end

  defp ensure_sale_allows_payment(%{status: :completed}),
    do: {:error, :sale_already_completed}

  defp ensure_sale_allows_payment(%{status: :cancelled}),
    do: {:error, :sale_already_cancelled}

  defp ensure_sale_allows_payment(%{status: :initiated}),
    do: :ok

  defp ensure_sale_allows_payment(_),
    do: {:error, :invalid_sale_state}

  defp ensure_sale_allows_payment(_),
    do: {:error, :persistence_error}
end
