defmodule AutoGrandPremiumOutletWeb.PaymentController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Payments.{
    CreatePayment,
    ConfirmPayment,
    CancelPayment
  }

  alias AutoGrandPremiumOutletWeb.PaymentSerializer

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def create(conn, params) do
    with {:ok, payment} <-
           CreatePayment.execute(
             params,
             payment_repo(),
             sale_repo()
           ) do
      conn
      |> put_status(:created)
      |> json(PaymentSerializer.serialize(payment))
    end
  end

  def confirm(conn, %{"payment_code" => code}) do
    with {:ok, payment} <-
           ConfirmPayment.execute(
             code,
             payment_repo(),
             sale_repo()
           ) do
      json(conn, PaymentSerializer.serialize(payment))
    end
  end

  def cancel(conn, %{"payment_code" => code}) do
    with {:ok, payment} <-
           CancelPayment.execute(
             code,
             payment_repo()
           ) do
      json(conn, PaymentSerializer.serialize(payment))
    end
  end

  ## -------- deps --------

  defp payment_repo do
    Application.fetch_env!(:auto_grand_premium_outlet, :payment_repo)
  end

  defp sale_repo do
    Application.fetch_env!(:auto_grand_premium_outlet, :sale_repo)
  end
end
