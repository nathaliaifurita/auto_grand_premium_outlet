defmodule AutoGrandPremiumOutletWeb.SaleControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: false

  alias AutoGrandPremiumOutlet.Domain.Vehicle
  alias AutoGrandPremiumOutlet.Domain.Sale
  # alias AutoGrandPremiumOutletWeb.SaleSerializer

  ## -------- Mocks --------

  defmodule VehicleRepoMock do
    @vehicle %Vehicle{
      id: "vehicle-123",
      brand: "Toyota",
      model: "Corolla",
      year: 2022,
      color: "Preto",
      price: 120_000,
      license_plate: "ABC12345",
      status: :available,
      inserted_at: ~U[2025-12-29 03:43:35.033324Z],
      updated_at: nil,
      sold_at: nil
    }
    def create(%Vehicle{} = vehicle), do: {:ok, vehicle}

    def get("123"), do: {:ok, @vehicle}
    def get("vehicle-123"), do: {:ok, @vehicle}
    def get(_), do: {:error, :not_found}

    def update(%Vehicle{} = vehicle), do: {:ok, vehicle}
  end

  defmodule SaleRepoMock do
    @sale %Sale{
      id: "sale-123",
      vehicle_id: "123",
      buyer_cpf: "12345678901",
      status: :initiated,
      inserted_at: ~U[2025-12-29 03:43:35.033324Z],
      updated_at: nil
    }
    def create(%Sale{} = sale), do: {:ok, %{sale | id: "sale-123"}}

    def get("sale-123"), do: {:ok, @sale}
    def get(_), do: {:error, :not_found}

    def update(%Sale{} = sale), do: {:ok, sale}
  end

  #
  # -------- SETUP --------
  #

  setup do
    Application.put_env(:auto_grand_premium_outlet, :sale_repo, SaleRepoMock)
    Application.put_env(:auto_grand_premium_outlet, :vehicle_repo, VehicleRepoMock)

    :ok
  end

  #
  # -------- CREATE --------
  #

  describe "POST /api/sales" do
    test "creates a sale with valid params", %{conn: conn} do
      conn =
        post(conn, "/api/sales", %{
          "vehicle_id" => "123",
          "buyer_cpf" => "12345678901"
        })

      assert %{"id" => "sale-123"} = json_response(conn, 201)
    end

    test "returns 404 when vehicle is not found", %{conn: conn} do
      conn =
        post(conn, "/api/sales", %{
          "vehicle_id" => "invalid",
          "buyer_cpf" => "12345678901"
        })

      assert json_response(conn, 404)["error"] == "vehicle_not_found"
    end
  end

  #
  # -------- GET --------
  #
  describe "GET /api/sales/:sale_id" do
    test "get a sale state by sale_id", %{conn: conn} do
      sale_id = "sale-123"

      conn =
        get(conn, "/api/sales/#{sale_id}")

      assert json_response(conn, 200)["status"] == "initiated"
    end

    test "returns error when sale is not_found", %{conn: conn} do
      sale_id = "sale-010"

      conn =
        get(conn, "/api/sales/#{sale_id}")

      assert json_response(conn, 404)["error"] == "sale_not_found"
    end
  end
end
