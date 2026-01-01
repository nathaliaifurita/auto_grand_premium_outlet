# defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPaymentTest do
#   use ExUnit.Case, async: true

#   alias AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment
#   alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

#   ## ---- Fake Repositories ----

#   defmodule FakePaymentRepo do
#     def get_by_payment_code("pay-ok") do
#       {:ok,
#        %Payment{
#          id: "p1",
#          payment_code: "pay-ok",
#          sale_id: "sale-1",
#          amount: 100_000,
#          payment_status: :in_process,
#          inserted_at: DateTime.utc_now()
#        }}
#     end

#     def get_by_payment_code("pay-not-found"),
#       do: {:error, :payment_not_found}

#     def update(payment), do: {:ok, payment}
#   end

#   defmodule FakeSaleRepo do
#     def get("sale-1") do
#       {:ok,
#        %Sale{
#          id: "sale-1",
#          vehicle_id: "vehicle-1",
#          buyer_cpf: "12345678901",
#          status: :initiated,
#          inserted_at: DateTime.utc_now()
#        }}
#     end

#     def update(sale), do: {:ok, sale}
#   end

#   defmodule SoldSaleRepo do
#     %Sale{
#       id: "sale-1",
#       vehicle_id: "vehicle-1",
#       buyer_cpf: "12345678901",
#       status: :completed,
#       inserted_at: DateTime.utc_now()
#     }

#     def get("sale-1") do
#       {:error, :sale_already_completed}
#     end

#     def update(_), do: {:ok, :ignored}
#   end

#   ## ---- Tests ----

#   test "confirm payment and sale is successfully completed" do
#     assert {:ok, payment} =
#              ConfirmPayment.execute(
#                "pay-ok",
#                FakePaymentRepo,
#                FakeSaleRepo
#              )

#     assert payment.payment_status == :paid
#   end

#   test "returns error when payment is not found" do
#     assert {:error, :payment_not_found} =
#              ConfirmPayment.execute(
#                "pay-not-found",
#                FakePaymentRepo,
#                FakeSaleRepo
#              )
#   end

#   test "returns error when sale is not found" do
#     defmodule MissingSaleRepo do
#       def get_by_payment_code("pay-1") do
#         {:ok,
#          %Payment{
#            id: "p1",
#            payment_code: "pay-1",
#            sale_id: "sale-not-found",
#            amount: 100_000,
#            payment_status: :in_process,
#            inserted_at: DateTime.utc_now()
#          }}
#       end

#       def get("sale-not-found"), do: {:error, :sale_not_found}
#       def update(_), do: {:ok, :ignored}
#     end

#     assert {:error, :sale_not_found} =
#              ConfirmPayment.execute(
#                "pay-1",
#                FakePaymentRepo,
#                MissingSaleRepo
#              )
#   end

#   test "returns error when sale is :completed" do
#     defmodule MissingSaleRepo do
#       def get_by_payment_code("pay-ok") do
#         {:ok, %Payment{payment_status: :completed}}
#       end

#       def get("sale-completed"), do: {:error, :sale_already_completed}
#     end

#     assert {:error, :sale_already_completed} =
#              ConfirmPayment.execute(
#                "pay-ok",
#                FakePaymentRepo,
#                MissingSaleRepo
#              )
#   end
# end

defmodule AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPaymentTest do
  use ExUnit.Case, async: true

  alias AutoGrandPremiumOutlet.UseCases.Payments.ConfirmPayment
  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  ## -------- Fake Payment Repos --------

  defmodule PaymentRepoOk do
    def get_by_payment_code("pay-ok") do
      {:ok,
       %Payment{
         id: "p1",
         payment_code: "pay-ok",
         sale_id: "sale-1",
         amount: 100_000,
         payment_status: :in_process,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(payment), do: {:ok, payment}
  end

  defmodule PaymentRepoPaid do
    def get_by_payment_code("pay-paid") do
      {:ok,
       %Payment{
         id: "p2",
         payment_code: "pay-paid",
         sale_id: "sale-1",
         amount: 100_000,
         payment_status: :paid,
         inserted_at: DateTime.utc_now()
       }}
    end
  end

  defmodule PaymentRepoNotFound do
    def get_by_payment_code(_), do: {:error, :not_found}
  end

  ## -------- Fake Sale Repos --------

  defmodule SaleRepoInitiated do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now()
       }}
    end

    def update(sale), do: {:ok, sale}
  end

  defmodule SaleRepoCompleted do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :completed,
         inserted_at: DateTime.utc_now()
       }}
    end
  end

  defmodule SaleRepoNotFound do
    def get(_), do: {:error, :not_found}
  end

  ## -------- Tests --------

  test "successfully confirms payment and completes sale" do
    assert {:ok, payment} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoInitiated
             )

    assert payment.payment_status == :paid
  end

  test "returns error when payment is not found" do
    assert {:error, :payment_not_found} =
             ConfirmPayment.execute(
               "pay-x",
               PaymentRepoNotFound,
               SaleRepoInitiated
             )
  end

  test "returns error when payment is already paid" do
    assert {:error, :payment_already_paid} =
             ConfirmPayment.execute(
               "pay-paid",
               PaymentRepoPaid,
               SaleRepoInitiated
             )
  end

  test "returns error when sale is not found" do
    assert {:error, :sale_not_found} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoNotFound
             )
  end

  test "returns error when sale is already completed" do
    assert {:error, :sale_already_completed} =
             ConfirmPayment.execute(
               "pay-ok",
               PaymentRepoOk,
               SaleRepoCompleted
             )
  end
end
