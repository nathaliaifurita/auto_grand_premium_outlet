defmodule AutoGrandPremiumOutletWeb.PaymentController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Payments.{
    CreatePayment,
    ConfirmPayment,
    CancelPayment
  }

  alias AutoGrandPremiumOutletWeb.PaymentSerializer
  alias AutoGrandPremiumOutletWeb.BaseController

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def create(conn, params) do
    with {:ok, payment} <-
           CreatePayment.execute(
             params,
             BaseController.payment_repo(),
             BaseController.sale_repo(),
             BaseController.id_generator(),
             BaseController.code_generator(),
             BaseController.clock()
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
             BaseController.payment_repo(),
             BaseController.sale_repo(),
             BaseController.clock()
           ) do
      json(conn, PaymentSerializer.serialize(payment))
    end
  end

  def cancel(conn, %{"payment_code" => code}) do
    with {:ok, payment} <-
           CancelPayment.execute(
             code,
             BaseController.payment_repo(),
             BaseController.clock()
           ) do
      json(conn, PaymentSerializer.serialize(payment))
    end
  end
end
