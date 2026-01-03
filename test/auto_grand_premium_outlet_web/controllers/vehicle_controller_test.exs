defmodule AutoGrandPremiumOutletWeb.VehicleControllerTest do
  use AutoGrandPremiumOutletWeb.ConnCase, async: true

  describe "POST /api/vehicles" do
    test "creates a vehicle with valid params", %{conn: conn} do
      conn =
        post(conn, "/api/vehicles", %{
          id: 2,
          brand: "Renault",
          model: "Sandero",
          year: 2021,
          color: "Vermelho",
          price: 70_000,
          license_plate: "ABC1236"
        })

      response = json_response(conn, 201)

      assert response["brand"] == "Renault"
      assert response["model"] == "Sandero"
      assert response["year"] == 2021
      assert response["status"] == "available"
    end

    test "returns 422 when params are invalid", %{conn: conn} do
      conn =
        post(conn, "/api/vehicles", %{
          year: 1800,
          price: -10
        })

      assert json_response(conn, 422)
    end
  end

  describe "GET /api/vehicles/available" do
    test "returns available vehicles ordered by price", %{conn: conn} do
      conn = get(conn, "/api/vehicles/available")
      response = json_response(conn, 200)

      assert length(response) == 2
      assert Enum.at(response, 0)["price"] == 30_000
      assert Enum.at(response, 1)["price"] == 90_000
    end
  end

  describe "GET /api/vehicles/sold" do
    test "returns sold vehicles ordered by price", %{conn: conn} do
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
          price: 130_000
        })

      response = json_response(conn, 200)
      assert response["price"] == 130_000
    end
  end

  describe "GET /api/vehicles/:id" do
    test "returns vehicle when found", %{conn: conn} do
      conn = get(conn, "/api/vehicles/135")

      response = json_response(conn, 200)
      assert response["brand"] == "Toyota"
    end

    test "returns 404 when vehicle is not found", %{conn: conn} do
      conn = get(conn, "/api/vehicles/999")
      assert json_response(conn, 404)
    end
  end
end
