defmodule AutoGrandPremiumOutlet.Domain.Services.CodeGenerator do
  @moduledoc """
  Port for code generation. This abstraction allows the domain to be independent
  of infrastructure concerns like :crypto.
  """

  @callback generate() :: String.t()
end

