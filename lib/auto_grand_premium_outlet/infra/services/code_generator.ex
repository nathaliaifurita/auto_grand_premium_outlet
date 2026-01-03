defmodule AutoGrandPremiumOutlet.Infra.Services.CodeGenerator do
  @behaviour AutoGrandPremiumOutlet.Domain.Services.CodeGenerator

  @impl true
  def generate do
    :crypto.strong_rand_bytes(8)
    |> Base.encode16()
  end
end
