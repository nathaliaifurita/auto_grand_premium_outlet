defmodule AutoGrandPremiumOutletWeb.SaleController do
  use AutoGrandPremiumOutletWeb, :controller

  alias AutoGrandPremiumOutlet.UseCases.Sales.{CreateSale, CompleteSale, CancelSale, GetSale}
  alias AutoGrandPremiumOutletWeb.SaleSerializer
  alias AutoGrandPremiumOutletWeb.BaseController

  action_fallback AutoGrandPremiumOutletWeb.FallbackController

  def index(conn, %{"sale_id" => sale_id}) do
    with {:ok, sale} <-
           GetSale.execute(sale_id, BaseController.sale_repo()) do
      json(conn, SaleSerializer.serialize(sale))
    end
  end

  ## -------- CREATE --------
  # POST /api/sales
  def create(conn, %{"vehicle_id" => vehicle_id, "buyer_cpf" => buyer_cpf}) do
    with {:ok, sale} <-
           CreateSale.execute(
             vehicle_id,
             buyer_cpf,
             BaseController.vehicle_repo(),
             BaseController.sale_repo(),
             BaseController.id_generator(),
             BaseController.clock()
           ) do
      conn
      |> put_status(:created)
      |> json(SaleSerializer.serialize(sale))
    end
  end

  ## -------- COMPLETE --------
  # PUT /api/sales/:sale_id/complete
  def complete(conn, %{"sale_id" => sale_id}) do
    with {:ok, sale} <-
           CompleteSale.execute(
             sale_id,
             BaseController.sale_repo(),
             BaseController.vehicle_repo(),
             BaseController.clock()
           ) do
      json(conn, SaleSerializer.serialize(sale))
    end
  end

  ## -------- CANCEL --------
  # PUT /api/sales/:sale_id/cancel
  def cancel(conn, %{"sale_id" => sale_id}) do
    with {:ok, sale} <-
           CancelSale.execute(sale_id, BaseController.sale_repo(), BaseController.clock()) do
      json(conn, SaleSerializer.serialize(sale))
    end
  end
end
