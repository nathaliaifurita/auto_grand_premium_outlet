defmodule AutoGrandPremiumOutletWeb.PaymentControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: false

  alias AutoGrandPremiumOutlet.Domain.{Payment, Sale}

  ## -------- Sale Repo Mock --------

  defmodule SaleRepoMock do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get("sale-2") do
      {:ok,
       %Sale{
         id: "sale-2",
         vehicle_id: "vehicle-2",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get(_), do: {:error, :not_found}
  end

  ## -------- Payment Repo Mock --------

  defmodule PaymentRepoMock do
    def save(%Payment{} = payment) do
      {:ok, payment}
    end

    def get_by_payment_code("PAY123") do
      {:ok,
       %Payment{
         id: "p1",
         payment_code: "PAY123",
         sale_id: "sale-1",
         amount: 70_000,
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code("PAY456") do
      {:ok,
       %Payment{
         id: "p1",
         payment_code: "PAY456",
         sale_id: "sale-2",
         amount: 70_000,
         payment_status: :in_process,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get_by_payment_code(_code), do: {:error, :not_found}

    def update(%Payment{} = payment), do: {:ok, payment}
    def update(_), do: {:error, :persistence_error}
  end

  defmodule SaleRepoMock do
    def get("sale-1") do
      {:ok,
       %Sale{
         id: "sale-1",
         vehicle_id: "vehicle-1",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def get("sale-2") do
      {:ok,
       %Sale{
         id: "sale-2",
         vehicle_id: "vehicle-2",
         buyer_cpf: "12345678901",
         status: :initiated,
         inserted_at: DateTime.utc_now(),
         updated_at: nil
       }}
    end

    def update(%Sale{} = sale) do
      {:ok, %{sale | updated_at: DateTime.utc_now()}}
    end
  end

  ## -------- Setup --------

  setup do
    Application.put_env(
      :auto_grand_premium_outlet,
      :payment_repo,
      PaymentRepoMock
    )

    Application.put_env(
      :auto_grand_premium_outlet,
      :sale_repo,
      SaleRepoMock
    )

    :ok
  end

  ## -------- Tests --------

  describe "POST /api/payments" do
    test "creates a payment with valid params", %{conn: conn} do
      params = %{
        "sale_id" => "sale-1",
        "amount" => 70_000
      }

      conn =
        post(conn, "/api/payments", params)

      response = json_response(conn, 201)

      assert %{
               "payment_code" => _code,
               "status" => "in_process",
               "amount" => 70_000,
               "sale_id" => "sale-1"
             } = response
    end
  end

  describe "PUT /api/payments/:payment_code/confirm" do
    test "confirms a payment", %{conn: conn} do
      payment_code = "PAY123"

      conn = put(conn, "/api/payments/#{payment_code}/confirm")
      response = json_response(conn, 200) |> IO.inspect(label: "Confirm Payment Response")

      assert response["payment_code"] == payment_code
      assert response["status"] == "paid"
    end
  end

  describe "PUT /api/payments/:payment_code/cancel" do
    test "cancels a payment", %{conn: conn} do
      payment_code = "PAY456"

      conn = put(conn, "/api/payments/#{payment_code}/cancel")
      response = json_response(conn, 200)

      assert response["payment_code"] == payment_code
      assert response["status"] == "cancelled"
    end
  end
end
