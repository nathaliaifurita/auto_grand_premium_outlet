# # defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment do
# #   alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

# #   alias AutoGrandPremiumOutlet.Domain.Repositories.{
# #     PaymentRepository,
# #     SaleRepository
# #   }

# #   @type error ::
# #           :payment_not_found
# #           | :payment_already_paid
# #           | :payment_already_cancelled
# #           | :invalid_state
# #           | :sale_not_found
# #           | :sale_already_completed
# #           | :sale_already_cancelled
# #           | :invalid_sale_state
# #           | :persistence_error

# #   @spec execute(String.t(), PaymentRepository.t(), SaleRepository.t()) ::
# #           {:ok, Payment.t()} | {:error, error()}
# #   def execute(payment_code, payment_repo, sale_repo) do
# #     with {:ok, payment} <- fetch_payment(payment_code, payment_repo),
# #          :ok <- validate_payment_state(payment),
# #          {:ok, sale} <- fetch_sale(payment, sale_repo),
# #          :ok <- validate_sale_state(sale),
# #          {:ok, sale} <- Sale.complete(sale),
# #          {:ok, payment} <- Payment.mark_as_paid(payment),
# #          {:ok, _} <- sale_repo.update(sale),
# #          {:ok, payment} <- payment_repo.update(payment) do
# #       {:ok, payment}
# #     else
# #       {:error, :not_found} ->
# #         {:error, :payment_not_found}

# #       {:error, :payment_already_paid} ->
# #         {:error, :payment_already_paid}

# #       {:error, :invalid_state} ->
# #         {:error, :invalid_state}

# #       {:error, :sale_not_found} ->
# #         {:error, :sale_not_found}

# #       {:error, _} ->
# #         {:error, :persistence_error}
# #     end
# #   end

# #   ## -------- validations --------

# #   defp validate_payment_state(%Payment{payment_status: :paid}),
# #     do: {:error, :payment_already_paid}

# #   defp validate_payment_state(%Payment{payment_status: :cancelled}),
# #     do: {:error, :payment_already_cancelled}

# #   defp validate_payment_state(%Payment{payment_status: :in_process}),
# #     do: :ok

# #   defp validate_payment_state(%Payment{payment_status: _status}),
# #     do: {:error, :invalid_state}

# #   defp validate_sale_state(%Sale{status: :completed}),
# #     do: {:error, :sale_already_completed}

# #   defp validate_sale_state(%Sale{status: :cancelled}),
# #     do: {:error, :sale_already_cancelled}

# #   defp validate_sale_state(%Sale{status: :initiated}),
# #     do: :ok

# #   defp validate_sale_state(%Sale{status: _status}),
# #     do: {:error, :invalid_sale_state}

# #   ## -------- fetchers --------

# #   defp fetch_payment(payment_code, payment_repo) do
# #     case payment_repo.get_by_payment_code(payment_code) do
# #       {:ok, payment} -> {:ok, payment}
# #       {:error, :not_found} -> {:error, :payment_not_found}
# #     end
# #   end

# #   defp fetch_sale(%Payment{sale_id: sale_id}, sale_repo) do
# #     case sale_repo.get(sale_id) do
# #       {:ok, sale} -> {:ok, sale}
# #       {:error, :not_found} -> {:error, :sale_not_found}
# #     end
# #   end
# # end

# defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment do
#   alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

#   alias AutoGrandPremiumOutlet.Domain.Repositories.{
#     PaymentRepository,
#     SaleRepository
#   }

#   @type error ::
#           :not_found
#           | :payment_already_paid
#           | :payment_already_cancelled
#           | :invalid_state
#           | :sale_not_found
#           | :sale_already_completed
#           | :sale_already_cancelled
#           | :invalid_sale_state
#           | :persistence_error

#   @spec execute(String.t(), PaymentRepository.t(), SaleRepository.t()) ::
#           {:ok, Payment.t()} | {:error, error()}
#   def execute(payment_code, payment_repo, sale_repo) do
#     with {:ok, payment} <- fetch_payment(payment_code, payment_repo),
#          :ok <- validate_payment(payment),
#          {:ok, sale} <- fetch_sale(payment.sale_id, sale_repo),
#          :ok <- validate_sale(sale),
#          {:ok, sale} <- Sale.complete(sale),
#          {:ok, payment} <- Payment.mark_as_paid(payment),
#          {:ok, _} <- sale_repo.update(sale),
#          {:ok, payment} <- payment_repo.update(payment) do
#       {:ok, payment}
#     else
#       {:error, reason}
#       when reason in [
#              :not_found,
#              :payment_already_paid,
#              :payment_already_cancelled,
#              :invalid_state,
#              :sale_not_found,
#              :sale_already_completed,
#              :sale_already_cancelled,
#              :invalid_sale_state
#            ] ->
#         {:error, reason}

#       _ ->
#         {:error, :persistence_error}
#     end
#   end

#   ## -------- validations --------

#   defp validate_payment(%Payment{payment_status: :paid}),
#     do: {:error, :payment_already_paid}

#   defp validate_payment(%Payment{payment_status: :cancelled}),
#     do: {:error, :payment_already_cancelled}

#   defp validate_payment(%Payment{payment_status: :in_process}),
#     do: :ok

#   defp validate_payment(_),
#     do: {:error, :invalid_state}

#   defp validate_sale(%Sale{status: :completed}),
#     do: {:error, :sale_already_completed}

#   defp validate_sale(%Sale{status: :cancelled}),
#     do: {:error, :sale_already_cancelled}

#   defp validate_sale(%Sale{status: :initiated}),
#     do: :ok

#   defp validate_sale(_),
#     do: {:error, :invalid_sale_state}

#   ## -------- fetchers --------

#   defp fetch_payment(payment_code, payment_repo) do
#     case payment_repo.get_by_payment_code(payment_code) do
#       {:ok, payment} -> {:ok, payment}
#       {:error, :not_found} -> {:error, :not_found}
#     end
#   end

#   defp fetch_sale(sale_id, sale_repo) do
#     case sale_repo.get(sale_id) do
#       {:ok, sale} -> {:ok, sale}
#       {:error, :not_found} -> {:error, :sale_not_found}
#     end
#   end
# end

defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment do
  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  alias AutoGrandPremiumOutlet.Domain.Repositories.{
    PaymentRepository,
    SaleRepository
  }

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

  @spec execute(String.t(), PaymentRepository.t(), SaleRepository.t()) ::
          {:ok, Payment.t()} | {:error, error()}
  def execute(payment_code, payment_repo, sale_repo) do
    with {:ok, payment} <- fetch_payment(payment_code, payment_repo),
         :ok <- validate_payment_state(payment),
         {:ok, sale} <- fetch_sale(payment.sale_id, sale_repo),
         :ok <- validate_sale_state(sale),
         {:ok, completed_sale} <- Sale.complete(sale),
         {:ok, paid_payment} <- Payment.mark_as_paid(payment),
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
