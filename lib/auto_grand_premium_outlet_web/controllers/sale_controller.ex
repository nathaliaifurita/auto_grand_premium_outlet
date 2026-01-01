defmodule AutoGrandPremiumOutletWeb.SaleController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Sales.CreateSale
  alias AutoGrandPremiumOutlet.UseCases.Sales.AddVehicleToSale
  alias AutoGrandPremiumOutlet.UseCases.Sales.CompleteSale
  alias AutoGrandPremiumOutlet.UseCases.Sales.CancelSale
  alias AutoGrandPremiumOutletWeb.SaleSerializer

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  ## -------- CREATE --------
  # POST /api/sales
  def create(conn, %{"vehicle_id" => vehicle_id, "buyer_cpf" => buyer_cpf}) do
    with {:ok, sale} <-
           CreateSale.execute(
             vehicle_id,
             buyer_cpf,
             vehicle_repo(),
             sale_repo()
           ) do
      conn
      |> put_status(:created)
      |> json(SaleSerializer.serialize(sale))
    end
  end

  ## -------- COMPLETE --------
  # PUT /api/sales/:sale_id/complete
  def complete(conn, %{"sale_id" => sale_id}) do
    with {:ok, sale} <- CompleteSale.execute(sale_id, sale_repo(), vehicle_repo()) do
      json(conn, SaleSerializer.serialize(sale))
    end
  end

  ## -------- CANCEL --------
  # PUT /api/sales/:sale_id/cancel
  def cancel(conn, %{"sale_id" => sale_id}) do
    with {:ok, sale} <- CancelSale.execute(sale_id, sale_repo()) do
      json(conn, SaleSerializer.serialize(sale))
    end
  end

  ## -------- helpers --------

  defp sale_repo do
    Application.fetch_env!(:auto_grand_premium_outlet, :sale_repo)
  end

  defp vehicle_repo do
    Application.fetch_env!(:auto_grand_premium_outlet, :vehicle_repo)
  end
end
