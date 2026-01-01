defmodule AutoGrandPremiumOutletWeb.VehicleControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: false

  alias AutoGrandPremiumOutlet.Domain.Vehicle

  #
  # Mock do repositório DEFINIDO NO PRÓPRIO TESTE
  #
  defmodule VehicleRepoMock do
    @vehicle %Vehicle{
      id: "135",
      brand: "Toyota",
      model: "Corolla",
      year: "2022",
      color: "Preto",
      price: 120_000,
      license_plate: "ABC1D35",
      status: :available,
      inserted_at: DateTime.utc_now(),
      updated_at: nil,
      sold_at: nil
    }

    def create(vehicle), do: {:ok, vehicle}

    def list() do
      [@vehicle]
    end

    def list(_filters) do
      [@vehicle]
    end

    ## -------- Available vehicles --------

    def list_available_ordered_by_price do
      [
        %Vehicle{
          id: "v1",
          brand: "Ford",
          model: "Ka",
          year: 2018,
          color: "white",
          price: 30_000,
          license_plate: "ABC1240",
          status: :available
        },
        %Vehicle{
          id: "v2",
          brand: "BMW",
          model: "320i",
          year: 2020,
          color: "black",
          price: 90_000,
          license_plate: "DEF5678",
          status: :available
        }
      ]
    end

    ## -------- Sold vehicles --------

    def list_sold do
      [
        %Vehicle{
          id: "v3",
          brand: "Fiat",
          model: "Uno",
          year: 2015,
          color: "red",
          price: 25_000,
          license_plate: "GHI9999",
          status: :sold
        },
        %Vehicle{
          id: "v4",
          brand: "Audi",
          model: "A4",
          year: 2021,
          color: "silver",
          price: 120_000,
          license_plate: "JKL0001",
          status: :sold
        }
      ]
    end

    def get("135"), do: {:ok, @vehicle}
    def get(_), do: {:error, :not_found}

    def update(%Vehicle{} = vehicle) do
      {:ok, %{vehicle | updated_at: DateTime.utc_now()}}
    end
  end

  setup do
    Application.put_env(
      :auto_grand_premium_outlet,
      :vehicle_repo,
      VehicleRepoMock
    )

    :ok
  end

  describe "POST /api/vehicles" do
    test "creates a vehicle with valid params", %{conn: conn} do
      conn =
        post(conn, "/api/vehicles", %{
          id: 2,
          brand: "Renault",
          color: "Vermelho",
          price: 70_000,
          license_plate: "ABC1236",
          model: "Sandero",
          year: 2021
        })

      response = json_response(conn, 201)

      assert response["id"] == 2
      assert response["brand"] == "Renault"
      assert response["model"] == "Sandero"
      assert response["year"] == 2021
      assert response["color"] == "Vermelho"
      assert response["price"] == 70_000
      assert response["license_plate"] == "ABC1236"
      assert response["status"] == "available"
    end

    test "returns 422 when params are invalid", %{conn: conn} do
      conn =
        post(conn, "/api/vehicles", %{
          "year" => "1800",
          "price" => -10
        })

      assert json_response(conn, 422)
    end
  end

  describe "GET /api/vehicles" do
    test "GET /api/vehicles returns available vehicles ordered by price", %{conn: conn} do
      conn = get(conn, "/api/vehicles")
      response = json_response(conn, 200)

      assert length(response) == 2

      [first, second] = response

      assert first["id"] == "v1"
      assert first["price"] == 30_000

      assert second["id"] == "v2"
      assert second["price"] == 90_000
    end
  end

  describe "GET /api/vehicles/sold" do
    test "GET /api/vehicles/sold returns sold vehicles ordered by price", %{conn: conn} do
      conn = get(conn, "/api/vehicles/sold")
      response = json_response(conn, 200)

      assert Enum.at(response, 0)["price"] == 25_000
      assert Enum.at(response, 1)["price"] == 120_000
    end
  end

  describe "PUT /api/vehicles/:id" do
    test "updates a vehicle", %{conn: conn} do
      conn =
        put(conn, "/api/vehicles/135", %{
          "price" => 130_000
        })

      assert %{
               "id" => "135",
               "price" => 130_000
             } = json_response(conn, 200)
    end
  end

  describe "GET /api/vehicles/:id" do
    test "returns vehicle when found", %{conn: conn} do
      conn = get(conn, "/api/vehicles/135")

      assert %{
               "id" => "135",
               "brand" => "Toyota"
             } = json_response(conn, 200)
    end

    test "returns 404 when vehicle is not found", %{conn: conn} do
      conn = get(conn, "/api/vehicles/999")

      assert json_response(conn, 404)
    end
  end
end
