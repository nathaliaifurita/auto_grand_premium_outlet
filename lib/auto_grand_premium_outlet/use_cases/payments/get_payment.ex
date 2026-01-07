defmodule AutoGrandPremiumOutlet.UseCases.Payments.GetPayment do
  @moduledoc """
  Use case to retrieve a payment by payment_code.
  """

  alias AutoGrandPremiumOutlet.Domain.Payment
  alias AutoGrandPremiumOutlet.Domain.Repositories.PaymentRepository

  @type error ::
          :payment_not_found

  @spec execute(
          String.t(),
          PaymentRepository.t()
        ) :: {:ok, Payment.t()} | {:error, error()}
  def execute(payment_code, payment_repo) do
    case payment_repo.get_by_payment_code(payment_code) do
      {:ok, %Payment{} = payment} ->
        {:ok, payment}

      {:error, :not_found} ->
        {:error, :payment_not_found}

      {:error, :payment_not_found} ->
        {:error, :payment_not_found}
    end
  end
end
