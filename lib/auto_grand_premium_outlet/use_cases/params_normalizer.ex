defmodule AutoGrandPremiumOutlet.UseCases.ParamsNormalizer do
  @moduledoc """
  Utility module for normalizing parameters from external sources (e.g., HTTP requests).
  
  This module handles the conversion of string keys to atoms and type conversions
  that are necessary when receiving data from external sources like HTTP controllers.
  
  This normalization should happen in the application layer (use cases), not in the domain layer.
  """

  @doc """
  Normalizes vehicle parameters by:
  - Converting string keys to atoms
  - Converting string values to integers for :year and :price
  """
  @spec normalize_vehicle_params(map()) :: map()
  def normalize_vehicle_params(attrs) when is_map(attrs) do
    for {k, v} <- attrs, into: %{} do
      key = normalize_key(k)

      value =
        case key do
          :year when is_binary(v) ->
            String.to_integer(v)

          :price when is_binary(v) ->
            String.to_integer(v)

          _ ->
            v
        end

      {key, value}
    end
  end

  def normalize_vehicle_params(attrs), do: attrs

  @doc """
  Normalizes generic parameters by converting string keys to atoms.
  Used for payment and other parameters that don't need type conversion.
  """
  @spec normalize_params(map()) :: map()
  def normalize_params(attrs) when is_map(attrs) do
    for {k, v} <- attrs, into: %{} do
      {normalize_key(k), v}
    end
  end

  def normalize_params(attrs), do: attrs

  ## -------- Private helpers --------

  defp normalize_key(k) when is_binary(k), do: String.to_existing_atom(k)
  defp normalize_key(k), do: k
end

