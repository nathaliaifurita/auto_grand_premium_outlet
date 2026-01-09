defmodule AutoGrandPremiumOutletWeb.Router do
  use AutoGrandPremiumOutletWeb, :router
  # alias PhoenixSwaggerUI.Plug, as: PhoenixSwaggerUI

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AutoGrandPremiumOutletWeb do
    pipe_through :api

    scope "/vehicles" do
      post "/", VehicleController, :create
      put "/:id", VehicleController, :update
      get "/available", VehicleController, :index
      get "/sold", VehicleController, :sold
      get "/:id", VehicleController, :show
    end

    scope "/sales" do
      get "/:sale_id", SaleController, :index
      post "/", SaleController, :create
    end

    scope "/payments" do
      post "/", PaymentController, :create
      get "/:payment_code", PaymentController, :index
    end

    scope "/webhooks" do
      put "/payments", PaymentWebhookController, :handle
    end
  end

  # LiveDashboard
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: AutoGrandPremiumOutletWeb.Telemetry
    end
  end

  # Swoosh mailbox
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
