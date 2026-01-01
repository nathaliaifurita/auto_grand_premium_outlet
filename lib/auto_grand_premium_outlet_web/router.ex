defmodule AutoGrandPremiumOutletWeb.Router do
  use AutoGrandPremiumOutletWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", AutoGrandPremiumOutletWeb do
    pipe_through :api

    scope "/vehicles" do
      post "/", VehicleController, :create
      put "/:id", VehicleController, :update
      get "/", VehicleController, :index
      get "/sold", VehicleController, :sold
      get "/:id", VehicleController, :show
    end

    scope "/sales" do
      post "/", SaleController, :create
      # post "/:sale_id/vehicles/:vehicle_id", SaleController, :add_vehicle
      put "/:sale_id/complete", SaleController, :complete
      put "/:sale_id/cancel", SaleController, :cancel
    end

    scope "/payments" do
      post "/", PaymentController, :create
      put "/:payment_code/confirm", PaymentController, :confirm
      put "/:payment_code/cancel", PaymentController, :cancel
    end

    scope "/webhooks" do
      put "/payments/confirm", PaymentWebhookController, :confirm
      put "/payments/cancel", PaymentWebhookController, :cancel
    end

    scope "/swagger" do
      forward "/", PhoenixSwaggerUI.Plug,
        otp_app: :auto_grand_premium_outlet,
        swagger_file: "openapi/openapi.yaml"
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
