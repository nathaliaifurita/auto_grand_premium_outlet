defmodule AutoGrandPremiumOutletWeb.BaseController do
  @moduledoc """
  Base controller with shared helper functions to avoid code duplication.
  Provides common dependency injection helpers used across all controllers.
  """

  @doc """
  Fetches a repository or service from application environment.
  """
  def fetch_dependency(key) do
    Application.fetch_env!(:auto_grand_premium_outlet, key)
  end

  # Repository helpers
  def vehicle_repo, do: fetch_dependency(:vehicle_repo)
  def sale_repo, do: fetch_dependency(:sale_repo)
  def payment_repo, do: fetch_dependency(:payment_repo)

  # Service helpers
  def id_generator, do: fetch_dependency(:id_generator)
  def code_generator, do: fetch_dependency(:code_generator)
  def clock, do: fetch_dependency(:clock)
end
