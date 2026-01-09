defmodule AutoGrandPremiumOutletWeb.PaymentWebhookController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Payments.{
    ConfirmPayment,
    CancelPayment
  }

  alias AutoGrandPremiumOutletWeb.BaseController

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def handle(conn, %{"payment_code" => payment_code, "status" => status}) do
    case map_status(status) do
      :confirm ->
        with {:ok, _payment} <-
               ConfirmPayment.execute(
                 payment_code,
                 BaseController.payment_repo(),
                 BaseController.sale_repo(),
                 BaseController.vehicle_repo(),
                 BaseController.clock()
               ) do
          json(conn, %{message: "Confirmed Payment"})
        end

      :cancel ->
        with {:ok, _payment} <-
               CancelPayment.execute(
                 payment_code,
                 BaseController.payment_repo(),
                 BaseController.sale_repo(),
                 BaseController.clock()
               ) do
          json(conn, %{message: "Cancelled Payment"})
        end

      :ignore ->
        # status que não mudam nada (ex: in_process), responde 200 pra não re-tentar
        send_resp(conn, :ok, "No action taken")

      :unknown ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "invalid_payment_state", status: status})
    end
  end

  # -------- status mapping --------

  defp map_status("approved"), do: :confirm
  defp map_status("paid"), do: :confirm

  defp map_status("rejected"), do: :cancel
  defp map_status("cancelled"), do: :cancel

  defp map_status("in_process"), do: :ignore
  defp map_status("pending"), do: :ignore

  defp map_status(_), do: :unknown
end
