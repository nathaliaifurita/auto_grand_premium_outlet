defmodule AutoGrandPremiumOutletWeb.PaymentSerializer do

  def serialize(payment) do
    %{
      id: payment.id,
      payment_code: payment.payment_code,
      amount: payment.amount,
      sale_id: payment.sale_id,
      status: payment.payment_status,
      inserted_at: payment.inserted_at
    }
  end
end
