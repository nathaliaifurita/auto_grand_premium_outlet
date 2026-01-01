defmodule AutoGrandPremiumOutletWeb.PaymentWebhookController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Payments.{
    ConfirmPayment,
    CancelPayment
  }

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  ## -------- CONFIRM --------

  def confirm(conn, %{"payment_code" => payment_code}) do
    with {:ok, _payment} <-
           ConfirmPayment.execute(
             payment_code,
             payment_repo(),
             sale_repo()
           ) do
      send_resp(conn, :ok, "Confirmed Payment")
    end
  end

  ## -------- CANCEL --------

  def cancel(conn, %{"payment_code" => payment_code}) do
    with {:ok, _payment} <-
           CancelPayment.execute(
             payment_code,
             payment_repo()
           ) do
      send_resp(conn, :ok, "")
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
