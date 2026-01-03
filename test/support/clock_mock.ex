defmodule AutoGrandPremiumOutlet.Test.Support.Services.ClockMock do
  @moduledoc """
  Mock implementation of Clock for testing.
  Returns a fixed DateTime for predictable tests.
  """

  @behaviour AutoGrandPremiumOutlet.Domain.Services.Clock

  @impl true
  def now() do
    # Return a fixed DateTime for predictable tests
    # Can be customized per test if needed
    ~U[2024-01-01 12:00:00Z]
  end
end

