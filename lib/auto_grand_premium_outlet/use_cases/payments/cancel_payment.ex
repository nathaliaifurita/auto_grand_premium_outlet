defmodule AutoGrandPremiumOutlet.UseCases.Payments.CancelPayment do
  alias AutoGrandPremiumOutlet.Domain.Payment
  alias AutoGrandPremiumOutlet.Domain.Repositories.PaymentRepository

  @type error ::
          :payment_not_found
          | :payment_already_paid
          | :payment_already_cancelled
          | :invalid_payment_state
          | :persistence_error

  @spec execute(String.t(), PaymentRepository.t()) ::
          {:ok, Payment.t()} | {:error, error()}
  def execute(payment_code, payment_repo) do
    with {:ok, payment} <- fetch_payment(payment_code, payment_repo),
         :ok <- validate_payment_state(payment),
         {:ok, payment} <- Payment.cancel(payment),
         {:ok, payment} <- payment_repo.update(payment) do
      {:ok, payment}
    else
      {:error, :payment_not_found} ->
        {:error, :payment_not_found}

      {:error, :payment_already_paid} ->
        {:error, :payment_already_paid}

      {:error, :payment_already_cancelled} ->
        {:error, :payment_already_cancelled}

      {:error, :invalid_payment_state} ->
        {:error, :invalid_payment_state}

      {:error, _} ->
        {:error, :persistence_error}
    end
  end

  ## -------- helpers --------

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

  defp validate_payment_state(%Payment{payment_status: :in_process}),
    do: :ok

  defp validate_payment_state(%Payment{payment_status: :paid}),
    do: {:error, :payment_already_paid}

  defp validate_payment_state(%Payment{payment_status: :cancelled}),
    do: {:error, :payment_already_cancelled}

  defp validate_payment_state(%Payment{payment_status: _status}),
    do: {:error, :invalid_payment_state}
end
