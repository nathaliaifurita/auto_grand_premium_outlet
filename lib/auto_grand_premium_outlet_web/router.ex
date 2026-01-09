# defmodule AutoGrandPremiumOutletWeb.Router do
#   use AutoGrandPremiumOutletWeb, :router
#   alias PhoenixSwaggerUI.Plug, as: PhoenixSwaggerUI

#   forward "/docs", PhoenixSwaggerUI.Plug,
#   otp_app: :auto_grand_premium_outlet,
#   swagger_file: "openapi.yaml"

#   pipeline :api do
#     plug :accepts, ["json"]
#   end

#   scope "/api", AutoGrandPremiumOutletWeb do
#     pipe_through :api

#     scope "/vehicles" do
#       post "/", VehicleController, :create
#       put "/:id", VehicleController, :update
#       get "/available", VehicleController, :index
#       get "/sold", VehicleController, :sold
#       get "/:id", VehicleController, :show
#     end

#     scope "/sales" do
#       get "/:sale_id", SaleController, :index
#       post "/", SaleController, :create
#     end

#     scope "/payments" do
#       post "/", PaymentController, :create
#       get "/:payment_code", PaymentController, :index
#     end

#     scope "/webhooks" do
#       put "/payments", PaymentWebhookController, :handle
#     end
#   end

#   # LiveDashboard
#   if Mix.env() in [:dev, :test] do
#     import Phoenix.LiveDashboard.Router

#     scope "/" do
#       pipe_through [:fetch_session, :protect_from_forgery]
#       live_dashboard "/dashboard", metrics: AutoGrandPremiumOutletWeb.Telemetry
#     end
#   end

#   # Swoosh mailbox
#   if Mix.env() == :dev do
#     scope "/dev" do
#       pipe_through [:fetch_session, :protect_from_forgery]
#       forward "/mailbox", Plug.Swoosh.MailboxPreview
#     end
#   end
# end

defmodule AutoGrandPremiumOutletWeb.Router do
  use AutoGrandPremiumOutletWeb, :router

  # -------------------------
  # Swagger / OpenAPI UI
  # -------------------------
  forward "/docs", PhoenixSwaggerUI.Plug,
    otp_app: :auto_grand_premium_outlet,
    swagger_file: "../priv/static/swagger/openapi.yaml"

  # -------------------------
  # Pipelines
  # -------------------------
  pipeline :api do
    plug :accepts, ["json"]
  end

  # -------------------------
  # API Routes
  # -------------------------
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
      post "/", SaleController, :create
      get "/:sale_id", SaleController, :index
    end

    scope "/payments" do
      post "/", PaymentController, :create
      get "/:payment_code", PaymentController, :index
    end

    scope "/webhooks" do
      put "/payments", PaymentWebhookController, :handle
    end
  end

  # -------------------------
  # LiveDashboard
  # -------------------------
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard",
        metrics: AutoGrandPremiumOutletWeb.Telemetry
    end
  end

  # -------------------------
  # Swoosh Mailbox
  # -------------------------
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
