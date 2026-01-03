defmodule AutoGrandPremiumOutlet.Infra.Services.IdGenerator do
  @behaviour AutoGrandPremiumOutlet.Domain.Services.IdGenerator

  @impl true
  def generate do
    Ecto.UUID.generate()
  end
end

