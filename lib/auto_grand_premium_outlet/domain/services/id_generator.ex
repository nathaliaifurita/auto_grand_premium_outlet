defmodule AutoGrandPremiumOutlet.Domain.Services.IdGenerator do
  @moduledoc """
  Port for ID generation. This abstraction allows the domain to be independent
  of infrastructure concerns like Ecto.UUID.
  """

  @callback generate() :: String.t()
end

