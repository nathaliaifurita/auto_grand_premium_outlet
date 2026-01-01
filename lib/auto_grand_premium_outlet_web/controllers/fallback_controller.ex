defmodule AutoGrandPremiumOutletWeb.FallbackController do
  use AutoGrandPremiumOutletWeb, :controller

  def call(conn, {:error, reason}) do
    {status, error, code} = map_error(reason)

    conn
    |> put_status(status)
    |> json(%{
      error: error,
      code: code
    })
  end

  ## -------- error mapping --------

  defp map_error(:not_found),
    do: {:not_found, "not_found", 404}

  defp map_error(:vehicle_not_found),
    do: {:not_found, "vehicle_not_found", 404}

  defp map_error(:sale_not_found),
    do: {:not_found, "sale_not_found", 404}

  defp map_error(:payment_not_found),
    do: {:not_found, "payment_not_found", 404}

  defp map_error(:vehicle_already_sold),
    do: {:unprocessable_entity, "vehicle_already_sold", 422}

  defp map_error(:sale_already_completed),
    do: {:unprocessable_entity, "sale_already_completed", 422}

  defp map_error(:payment_already_paid),
    do: {:unprocessable_entity, "payment_already_paid", 422}

  defp map_error(:sale_already_cancelled),
    do: {:unprocessable_entity, "sale_already_cancelled", 422}

  defp map_error(:payment_already_cancelled),
    do: {:unprocessable_entity, "payment_already_cancelled", 422}

  defp map_error(:invalid_sale_state),
    do: {:unprocessable_entity, "invalid_sale_state", 422}

  defp map_error(:invalid_payment_state),
    do: {:unprocessable_entity, "invalid_payment_state", 422}

  defp map_error(:invalid_license_plate),
    do: {:unprocessable_entity, "invalid_license_plate", 422}

  defp map_error(:invalid_price),
    do: {:unprocessable_entity, "invalid_price", 422}

  defp map_error(:invalid_state),
    do: {:unprocessable_entity, "invalid_state", 422}

  defp map_error(:invalid_year),
    do: {:unprocessable_entity, "invalid_year", 422}

  defp map_error(_),
    do: {:internal_server_error, "internal_error", 500}
end
