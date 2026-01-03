defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment do
  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    PaymentRepository,
    SaleRepository
  }

  alias AutoGrandPremiumOutlet.Domain.Services.Clock

  @type error ::
          :payment_not_found
          | :payment_already_paid
          | :payment_already_cancelled
          | :invalid_state
          | :sale_not_found
          | :sale_already_completed
          | :sale_already_cancelled
          | :invalid_sale_state
          | :persistence_error

  @spec execute(String.t(), PaymentRepository.t(), SaleRepository.t(), Clock.t()) ::
          {:ok, Payment.t()} | {:error, error()}
  def execute(payment_code, payment_repo, sale_repo, clock) do
    now = clock.now()

    with {:ok, payment} <- fetch_payment(payment_code, payment_repo),
         :ok <- validate_payment_state(payment),
         {:ok, sale} <- fetch_sale(payment.sale_id, sale_repo),
         :ok <- validate_sale_state(sale),
         {:ok, completed_sale} <- Sale.complete(sale, now),
         {:ok, paid_payment} <- Payment.mark_as_paid(payment, now),
         {:ok, _} <- sale_repo.update(completed_sale),
         {:ok, updated_payment} <- payment_repo.update(paid_payment) do
      {:ok, updated_payment}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  ## -------- validations --------

  defp validate_payment_state(%Payment{payment_status: :paid}),
    do: {:error, :payment_already_paid}

  defp validate_payment_state(%Payment{payment_status: :cancelled}),
    do: {:error, :payment_already_cancelled}

  defp validate_payment_state(%Payment{payment_status: :in_process}),
    do: :ok

  defp validate_payment_state(_),
    do: {:error, :invalid_payment_state}

  defp validate_sale_state(%Sale{status: :completed}),
    do: {:error, :sale_already_completed}

  defp validate_sale_state(%Sale{status: :cancelled}),
    do: {:error, :sale_already_cancelled}

  defp validate_sale_state(%Sale{status: :initiated}),
    do: :ok

  defp validate_sale_state(_),
    do: {:error, :invalid_sale_state}

  ## -------- fetchers --------

  defp fetch_payment(payment_code, payment_repo) do
    case payment_repo.get_by_payment_code(payment_code) do
      {:ok, payment} ->
        {:ok, payment}

      {:error, :payment_not_found} ->
        {:error, :payment_not_found}

      _ ->
        {:error, :payment_not_found}
    end
  end

  defp fetch_sale(sale_id, sale_repo) do
    case sale_repo.get(sale_id) do
      {:ok, sale} -> {:ok, sale}
      {:error, :not_found} -> {:error, :sale_not_found}
    end
  end
end
