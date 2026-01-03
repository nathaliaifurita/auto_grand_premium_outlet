defmodule AutoGrandPremiumOutlet.UseCases.Payments.CreatePayment do
  @moduledoc """
  Use case responsible for creating a payment for a sale.
  """

  alias AutoGrandPremiumOutlet.Domain.Payment

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    PaymentRepository,
    SaleRepository
  }

  alias AutoGrandPremiumOutlet.Domain.Services.{
    IdGenerator,
    CodeGenerator,
    Clock
  }

  alias AutoGrandPremiumOutlet.UseCases.ParamsNormalizer

  @type error ::
          :invalid_amount
          | :invalid_sale_id
          | :sale_not_found
          | :sale_already_completed
          | :sale_already_cancelled
          | :invalid_sale_state
          | :persistence_error

  @spec execute(
          map(),
          PaymentRepository.t(),
          SaleRepository.t(),
          IdGenerator.t(),
          CodeGenerator.t(),
          Clock.t()
        ) :: {:ok, Payment.t()} | {:error, error()}
  def execute(params, payment_repo, sale_repo, id_generator, code_generator, clock) do
    # Normalize parameters (string keys to atoms)
    normalized_params = ParamsNormalizer.normalize_params(params)

    sale_id = Map.get(normalized_params, :sale_id)
    amount = Map.get(normalized_params, :amount)

    with {:ok, sale} <- fetch_sale(sale_id, sale_repo),
         :ok <- ensure_sale_allows_payment(sale),
         {:ok, payment} <-
           Payment.new(%{
             id: id_generator.generate(),
             payment_code: code_generator.generate(),
             sale_id: sale_id,
             amount: amount,
             inserted_at: clock.now()
           }),
         {:ok, payment} <- payment_repo.save(payment) do
      {:ok, payment}
    else
      {:error, :sale_not_found} ->
        {:error, :sale_not_found}

      {:error, :invalid_amount} ->
        {:error, :invalid_amount}

      {:error, :invalid_sale_id} ->
        {:error, :invalid_sale_id}

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
end
