defmodule AutoGrandPremiumOutlet.Domain.Services.Clock do
  @moduledoc """
  Port for time operations, abstracting away
  of infrastructure concerns like DateTime.utc_now().
  """

  @callback now() :: DateTime.t()
end
