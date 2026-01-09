defmodule AutoGrandPremiumOutletWeb.PaymentWebhookControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: false

  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale, Vehicle}

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

    def get("sale-2") do
      {:ok,
       %Sale{
         id: "sale-2",
         vehicle_id: "141",
         buyer_cpf: "12345678909",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get("sale-3") do
      {:ok,
       %Sale{
         id: "sale-3",
         vehicle_id: "143",
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

    def get_by_payment_code("pay-to-be-cancelled") do
      {:ok,
       %Payment{
         id: "p2",
         payment_code: "pay-to-be-cancelled",
         amount: 100_000,
         sale_id: "sale-2",
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code("cancelled") do
      {:ok,
       %Payment{
         id: "p2",
         payment_code: "cancelled",
         amount: 100_000,
         sale_id: "sale-3",
         payment_status: :cancelled,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code(_), do: {:error, :payment_not_found}

    def update(%Payment{} = payment) do
      {:ok, %Payment{payment | updated_at: DateTime.utc_now()}}
    end
  end

  defmodule VehicleRepoMock do
    def get("137") do
      {:ok,
       %Vehicle{
         id: "137",
         brand: "Toyota",
         model: "Corolla",
         year: 2022,
         color: "Preto",
         price: 100_000,
         license_plate: "ABC1234",
         status: :available,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get("vehicle-sold") do
      {:ok,
       %Vehicle{
         id: "vehicle-sold",
         brand: "Honda",
         model: "Civic",
         year: 2021,
         color: "Branco",
         price: 100_000,
         license_plate: "XYZ5678",
         status: :sold,
         inserted_at: DateTime.utc_now()
       }}
    end

    def get(_), do: {:error, :not_found}

    def update(%Vehicle{} = vehicle) do
      {:ok, vehicle}
    end
  end

  ## ------------------------------------------------------------------
  ## Setup / Teardown por teste (limpa Application env)
  ## ------------------------------------------------------------------

  setup do
    Application.put_env(:auto_grand_premium_outlet, :payment_repo, PaymentRepoMock)
    Application.put_env(:auto_grand_premium_outlet, :sale_repo, SaleRepoMock)
    Application.put_env(:auto_grand_premium_outlet, :vehicle_repo, VehicleRepoMock)

    on_exit(fn ->
      Application.delete_env(:auto_grand_premium_outlet, :payment_repo)
      Application.delete_env(:auto_grand_premium_outlet, :sale_repo)
      Application.delete_env(:auto_grand_premium_outlet, :vehicle_repo)
    end)

    :ok
  end

  ## ------------------------------------------------------------------
  ## CONFIRM
  ## ------------------------------------------------------------------

  describe "PUT /api/webhooks/payments" do
    test "200 OK when payment is confirmed", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "pay-ok",
          "status" => "paid"
        })

      assert conn.status == 200
    end

    test "404 when payment is not found", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "not-found",
          "status" => "paid"
        })

      assert json_response(conn, 404)["error"] == "payment_not_found"
    end

    test "422 when payment already paid", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "paid",
          "status" => "paid"
        })

      assert json_response(conn, 422)["error"] == "payment_already_paid"
    end

    test "200 OK when payment is cancelled", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "pay-to-be-cancelled",
          "status" => "cancelled"
        })

      assert conn.status == 200
    end

    test "422 when cancelling already cancelled payment", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "cancelled",
          "status" => "cancelled"
        })

      assert json_response(conn, 422)["error"] == "payment_already_cancelled"
    end

    test "422 for an invalid payment state", %{conn: conn} do
      conn =
        put(conn, "/api/webhooks/payments", %{
          "payment_code" => "cancelled",
          "status" => "progressing"
        })

      assert json_response(conn, 422)["error"] == "invalid_payment_state"
    end
  end
end
