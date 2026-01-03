defmodule AutoGrandPremiumOutlet.Infra.Services.Clock do
  @moduledoc """
  Infrastructure implementation of Clock service using DateTime.
  """

  @behaviour AutoGrandPremiumOutlet.Domain.Services.Clock

  @impl true
  def now(), do: DateTime.utc_now()
end
