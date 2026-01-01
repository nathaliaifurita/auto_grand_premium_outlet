# # defmodule AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest do
# #   use AutoGrandPremiumOutletWeb.ConnCase, async: true

# #   alias AutoGrandPremiumOutlet.Domain.{Payment, Sale, Vehicle}

# #   ## -------- Fake Repositories --------
# #   defmodule VehicleRepoMock do
# #     @vehicle %Vehicle{
# #       id: "137",
# #       brand: "Toyota",
# #       model: "Corolla",
# #       year: "2022",
# #       color: "Preto",
# #       price: 120_000,
# #       license_plate: "ABC1D35",
# #       status: :available,
# #       inserted_at: DateTime.utc_now(),
# #       updated_at: nil,
# #       sold_at: nil
# #     }

# #     def create(vehicle), do: {:ok, vehicle}
# #     def get("137"), do: {:ok, @vehicle}
# #     def get(_), do: {:error, :not_found}
# #   end

# #   defmodule FakeSaleRepo do
# #     def get("sale-1") do
# #       {:ok,
# #        %Sale{
# #          id: "sale-1",
# #          vehicle_id: "137",
# #          buyer_cpf: "12345678909",
# #          inserted_at: DateTime.utc_now(),
# #          status: :initiated
# #        }}
# #     end

# #     def get("sold") do
# #       {:ok,
# #        %Sale{
# #          id: "sold",
# #          vehicle_id: "vehicle-sold",
# #          buyer_cpf: "12345678909",
# #          inserted_at: DateTime.utc_now(),
# #          status: :completed
# #        }}
# #     end

# #     def get(_),
# #       do: {:error, :not_found}

# #     def update(%Sale{} = sale), do: {:ok, sale}
# #   end

# #   defmodule FakePaymentRepo do
# #     def get_by_payment_code("pay-ok-1") do
# #       {:ok,
# #        %Payment{
# #          id: "p1",
# #          payment_code: "pay-ok-1",
# #          amount: 100_000,
# #          sale_id: "sale-1",
# #          payment_status: :in_process,
# #          inserted_at: DateTime.utc_now()
# #        }}
# #     end

# #     def get_by_payment_code("paid") do
# #       {:ok,
# #        %Payment{
# #          id: "p2",
# #          payment_code: "paid",
# #          amount: 100_000,
# #          sale_id: "sale-1",
# #          payment_status: :paid,
# #          inserted_at: DateTime.utc_now()
# #        }}
# #     end

# #     def get_by_payment_code("not-found"),
# #       do: {:error, :not_found}

# #     def get_by_payment_code("nope"),
# #       do: {:error, :not_found}

# #     def get_by_payment_code(_),
# #       do: {:error, :not_found}

# #     def update(payment),
# #       do: {:ok, %Payment{payment | updated_at: DateTime.utc_now()}}
# #   end

# #   ## -------- Setup --------

# #   setup do
# #     Application.put_env(:auto_grand_premium_outlet, :payment_repo, FakePaymentRepo)
# #     Application.put_env(:auto_grand_premium_outlet, :sale_repo, FakeSaleRepo)

# #     on_exit(fn ->
# #       Application.delete_env(:auto_grand_premium_outlet, :payment_repo)
# #       Application.delete_env(:auto_grand_premium_outlet, :sale_repo)
# #     end)

# #     :ok
# #   end

# #   ## -------- CONFIRM --------

# #   describe "PUT /api/payments/confirm" do
# #     test "200 OK when payment is confirmed", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/confirm", %{
# #           "payment_code" => "pay-ok"
# #         })

# #       IO.inspect(conn, label: "Confirm Payment Conn")

# #       assert conn.status == 200
# #     end

# #     test "404 when payment is not found", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/confirm", %{
# #           "payment_code" => "not-found"
# #         })
# #         |> IO.inspect(label: "Not Found Confirm Conn")

# #       assert conn.status == 404
# #     end

# #     test "422 when payment already paid", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/confirm", %{
# #           "payment_code" => "paid"
# #         })

# #       assert conn.status == 422
# #     end
# #   end

# #   ## -------- CANCEL --------
# #   describe "PUT /api/payments/cancel" do
# #     test "200 OK when payment is cancelled", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/cancel", %{
# #           "payment_code" => "pay-ok"
# #         })

# #       assert conn.status == 200
# #     end

# #     test "404 when cancelling non-existing payment", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/cancel", %{
# #           "payment_code" => "nope"
# #         })

# #       assert conn.status == 404
# #     end

# #     test "422 when cancelling already paid payment", %{conn: conn} do
# #       conn =
# #         put(conn, "/api/webhooks/payments/cancel", %{
# #           "payment_code" => "paid"
# #         })

# #       assert conn.status == 422
# #     end
# #   end
# # end

# defmodule AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest do
#   use AutoGrandPremiumOutletWeb.ConnCase, async: true

#   alias AutoGrandPremiumOutlet.Domain.{Payment, Sale, Vehicle}

#   ## ------------------------------------------------------------------
#   ## Shared test data helpers
#   ## ------------------------------------------------------------------

#   defp now, do: DateTime.utc_now()

#   defp base_vehicle do
#     %Vehicle{
#       id: "137",
#       brand: "Toyota",
#       model: "Corolla",
#       year: "2022",
#       color: "Preto",
#       price: 120_000,
#       license_plate: "ABC1D35",
#       status: :available,
#       inserted_at: now(),
#       updated_at: nil,
#       sold_at: nil
#     }
#   end

#   defp base_sale(attrs \\ %{}) do
#     Map.merge(
#       %Sale{
#         id: "sale-1",
#         vehicle_id: "137",
#         buyer_cpf: "12345678909",
#         status: :initiated,
#         inserted_at: now(),
#         updated_at: nil
#       },
#       attrs
#     )
#   end

#   defp base_payment(attrs \\ %{}) do
#     Map.merge(
#       %Payment{
#         id: "p1",
#         payment_code: "pay-ok",
#         amount: 100_000,
#         sale_id: "sale-1",
#         payment_status: :in_process,
#         inserted_at: now(),
#         updated_at: nil
#       },
#       attrs
#     )
#   end

#   ## ------------------------------------------------------------------
#   ## Fake Repositories
#   ## ------------------------------------------------------------------

#   defmodule VehicleRepoMock do
#     def create(vehicle), do: {:ok, vehicle}

#     def get("137"),
#       do: {:ok, AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest.base_vehicle()}

#     def get(_),
#       do: {:error, :not_found}
#   end

#   defmodule FakeSaleRepo do
#     import AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest

#     def get("sale-1"),
#       do: {:ok, base_sale()}

#     def get("sold"),
#       do: {:ok, base_sale(%{id: "sold", status: :completed})}

#     def get(_),
#       do: {:error, :not_found}

#     def update(%Sale{} = sale),
#       do: {:ok, %{sale | updated_at: DateTime.utc_now()}}
#   end

#   defmodule FakePaymentRepo do
#     import AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest

#     def get_by_payment_code(code) do
#       case code do
#         "pay-ok" ->
#           {:ok, base_payment()}

#         "paid" ->
#           {:ok, base_payment(%{payment_code: "paid", payment_status: :paid})}

#         "not-found" ->
#           {:error, :not_found}

#         "nope" ->
#           {:error, :not_found}

#         _ ->
#           {:error, :not_found}
#       end
#     end

#     def update(%Payment{} = payment),
#       do: {:ok, %{payment | updated_at: DateTime.utc_now()}}
#   end

#   ## ------------------------------------------------------------------
#   ## Setup
#   ## ------------------------------------------------------------------

#   setup do
#     Application.put_env(:auto_grand_premium_outlet, :payment_repo, FakePaymentRepo)
#     Application.put_env(:auto_grand_premium_outlet, :sale_repo, FakeSaleRepo)
#     Application.put_env(:auto_grand_premium_outlet, :vehicle_repo, VehicleRepoMock)

#     on_exit(fn ->
#       Application.delete_env(:auto_grand_premium_outlet, :payment_repo)
#       Application.delete_env(:auto_grand_premium_outlet, :sale_repo)
#       Application.delete_env(:auto_grand_premium_outlet, :vehicle_repo)
#     end)

#     :ok
#   end

#   ## ------------------------------------------------------------------
#   ## CONFIRM
#   ## ------------------------------------------------------------------

#   describe "PUT /api/webhooks/payments/confirm" do
#     test "200 OK when payment is confirmed", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/confirm", %{
#           "payment_code" => "pay-ok"
#         })

#       assert conn.status == 200
#     end

#     test "404 when payment is not found", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/confirm", %{
#           "payment_code" => "not-found"
#         })

#       assert conn.status == 404
#     end

#     test "422 when payment already paid", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/confirm", %{
#           "payment_code" => "paid"
#         })

#       assert conn.status == 422
#     end
#   end

#   ## ------------------------------------------------------------------
#   ## CANCEL
#   ## ------------------------------------------------------------------

#   describe "PUT /api/webhooks/payments/cancel" do
#     test "200 OK when payment is cancelled", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/cancel", %{
#           "payment_code" => "pay-ok"
#         })

#       assert conn.status == 200
#     end

#     test "404 when cancelling non-existing payment", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/cancel", %{
#           "payment_code" => "nope"
#         })

#       assert conn.status == 404
#     end

#     test "422 when cancelling already paid payment", %{conn: conn} do
#       conn =
#         put(conn, "/api/webhooks/payments/cancel", %{
#           "payment_code" => "paid"
#         })

#       assert conn.status == 422
#     end
#   end
# end

defmodule AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: false

  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  ## ------------------------------------------------------------------
  ## Fake Repositories (isolados e reutilizáveis)
  ## ------------------------------------------------------------------

  defmodule SaleRepoMock do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "137",
         buyer_cpf: "12345678909",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get("sold") do
      {:ok,
       %Sale{
         id: "sold",
         vehicle_id: "vehicle-sold",
         buyer_cpf: "12345678909",
         status: :completed,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get(_), do: {:error, :sale_not_found}

    def update(%Sale{} = sale), do: {:ok, sale}
  end

  defmodule PaymentRepoMock do
    def get_by_payment_code("pay-ok") do
      {:ok,
       %Payment{
         id: "p1",
         payment_code: "pay-ok",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code("paid") do
      {:ok,
       %Payment{
         id: "p2",
         payment_code: "paid",
         amount: 100_000,
         sale_id: "sale-1",
         payment_status: :paid,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code(_), do: {:error, :payment_not_found}

    def get_by_payment_code("nope"), do: {:error, :payment_not_found}

    def update(%Payment{} = payment) do
      {:ok, %Payment{payment | updated_at: DateTime.utc_now()}}
    end
  end

  ## ------------------------------------------------------------------
  ## Setup / Teardown por teste (limpa Application env)
  ## ------------------------------------------------------------------

  setup do
    Application.put_env(:auto_grand_premium_outlet, :payment_repo, PaymentRepoMock)
    Application.put_env(:auto_grand_premium_outlet, :sale_repo, SaleRepoMock)

    on_exit(fn ->
      Application.delete_env(:auto_grand_premium_outlet, :payment_repo)
      Application.delete_env(:auto_grand_premium_outlet, :sale_repo)
    end)

    :ok
  end

  ## ------------------------------------------------------------------
  ## CONFIRM
  ## ------------------------------------------------------------------

  describe "PUT /api/webhooks/payments/confirm" do
    test "200 OK when payment is confirmed", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/confirm", %{
          "payment_code" => "pay-ok"
        })

      assert conn.status == 200
    end

    test "404 when payment is not found", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/confirm", %{
          "payment_code" => "not-found"
        })

      #   assert conn.status == 404
      assert json_response(conn, 404)["error"] == "payment_not_found"
    end

    test "422 when payment already paid", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/confirm", %{
          "payment_code" => "paid"
        })

      assert conn.status == 422
    end
  end

  ## ------------------------------------------------------------------
  ## CANCEL
  ## ------------------------------------------------------------------

  describe "PUT /api/webhooks/payments/cancel" do
    test "200 OK when payment is cancelled", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/cancel", %{
          "payment_code" => "pay-ok"
        })

      assert conn.status == 200
    end

    test "404 when cancelling non-existing payment", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/cancel", %{
          "payment_code" => "nope"
        })

      #   assert conn.status == 404
      assert json_response(conn, 404)["error"] == "payment_not_found"
    end

    test "422 when cancelling already paid payment", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments/cancel", %{
          "payment_code" => "paid"
        })

      assert conn.status == 422
    end
  end
end
