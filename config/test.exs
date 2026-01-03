# import Config

# # Configure your database
# #
# # The MIX_TEST_PARTITION environment variable can be used
# # to provide built-in test partitioning in CI environment.
# # Run `mix help test` for more information.
# config :auto_grand_premium_outlet, AutoGrandPremiumOutlet.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "auto_grand_premium_outlet_test#{System.get_env("MIX_TEST_PARTITION")}",
#   pool: Ecto.Adapters.SQL.Sandbox,
#   pool_size: 10

# # We don't run a server during test. If one is required,
# # you can enable the server option below.
# config :auto_grand_premium_outlet, AutoGrandPremiumOutletWeb.Endpoint,
#   http: [ip: {127, 0, 0, 1}, port: 4002],
#   secret_key_base: "Ni/aYTS5uQ9r1zXXJbce7PJxov/aA05f0rl+keNFU1RledN2wffCG1eWoFYX3Y0g",
#   server: false

# # In test we don't send emails.
# config :auto_grand_premium_outlet, AutoGrandPremiumOutlet.Mailer, adapter: Swoosh.Adapters.Test

# # Print only warnings and errors during test
# config :logger, level: :warn

# # Initialize plugs at runtime for faster test compilation
# config :phoenix, :plug_init_mode, :runtime

import Config

# -----------------------------
# Database configuration
# -----------------------------
config :auto_grand_premium_outlet, AutoGrandPremiumOutlet.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "auto_grand_premium_outlet_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# -----------------------------
# Clean Architecture ports (TEST)
# -----------------------------
config :auto_grand_premium_outlet,
  vehicle_repo: AutoGrandPremiumOutlet.Test.Support.Repositories.VehicleRepoMock,
  sale_repo: AutoGrandPremiumOutlet.Test.Support.Repositories.SaleRepoMock,
  payment_repo: AutoGrandPremiumOutlet.Test.Support.Repositories.PaymentRepoMock,
  id_generator: AutoGrandPremiumOutlet.Infra.Services.IdGenerator,
  code_generator: AutoGrandPremiumOutlet.Infra.Services.CodeGenerator

# (futuro)
# config :auto_grand_premium_outlet,
#   sale_repo: AutoGrandPremiumOutlet.Test.Support.SaleRepoMock,
#   payment_repo: AutoGrandPremiumOutlet.Test.Support.PaymentRepoMock

# -----------------------------
# Endpoint configuration
# -----------------------------
config :auto_grand_premium_outlet, AutoGrandPremiumOutletWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Ni/aYTS5uQ9r1zXXJbce7PJxov/aA05f0rl+keNFU1RledN2wffCG1eWoFYX3Y0g",
  server: false

# -----------------------------
# Mailer
# -----------------------------
config :auto_grand_premium_outlet, AutoGrandPremiumOutlet.Mailer, adapter: Swoosh.Adapters.Test

# -----------------------------
# Logger & Phoenix
# -----------------------------
config :logger, level: :warn

config :phoenix, :plug_init_mode, :runtime
