defmodule AutoGrandPremiumOutlet.Domain.Repositories.PaymentRepository do
  @moduledoc """
  Repository port for Payment persistence.
  """

  alias AutoGrandPremiumOutlet.Domain.Payment

  @type error :: :not_found | :persistence_error

  @callback save(Payment.t()) ::
              {:ok, Payment.t()} | {:error, error()}

  @callback get(String.t()) ::
              {:ok, Payment.t()} | {:error, :not_found}

  @callback get_by_payment_code(String.t()) ::
              {:ok, Payment.t()} | {:error, :not_found}

  @callback get_by_sale_id(String.t()) ::
              {:ok, Payment.t()} | {:error, :not_found}

  @callback update(Payment.t()) ::
              {:ok, Payment.t()} | {:error, error()}
end
