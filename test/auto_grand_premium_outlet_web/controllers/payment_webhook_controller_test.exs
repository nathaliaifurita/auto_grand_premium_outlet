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
