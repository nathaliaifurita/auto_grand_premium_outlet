defmodule AutoGrandPremiumOutlet.Infra.Repositories.PaymentRepo do
  @behaviour AutoGrandPremiumOutlet.Domain.Repositories.PaymentRepository

  alias AutoGrandPremiumOutlet.Domain.Payment

  ## -------- GET --------

  @impl true
  def get_by_payment_code(_code), do: {:error, :not_found}

  ## -------- CREATE --------

  @impl true
  def save(%Payment{} = payment) do
    {:ok, payment}
  end

  ## -------- UPDATE --------

  @impl true
  def update(%Payment{} = payment) do
    {:ok, payment}
  end
end
