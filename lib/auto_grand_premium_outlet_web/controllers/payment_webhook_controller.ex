defmodule AutoGrandPremiumOutletWeb.PaymentWebhookController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Payments.{
    ConfirmPayment,
    CancelPayment
  }

  alias AutoGrandPremiumOutletWeb.BaseController

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  ## -------- CONFIRM --------

  def confirm(conn, %{"payment_code" => payment_code}) do
    with {:ok, _payment} <-
           ConfirmPayment.execute(
             payment_code,
             BaseController.payment_repo(),
             BaseController.sale_repo(),
             BaseController.vehicle_repo(),
             BaseController.clock()
           ) do
      send_resp(conn, :ok, "Confirmed Payment")
    end
  end

  ## -------- CANCEL --------

  def cancel(conn, %{"payment_code" => payment_code}) do
    with {:ok, _payment} <-
           CancelPayment.execute(
             payment_code,
             BaseController.payment_repo(),
             BaseController.clock()
           ) do
      send_resp(conn, :ok, "")
    end
  end
end
