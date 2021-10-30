defmodule GuessWho.Contenders.BenNonRegex do
  @moduledoc """
  A contender that always picks the attribute closest to a 50% split and asks about it
  """

  alias GuessWho.Attributes

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "Ben (Non-regex)"

  @impl GuessWho.Contender
  def turn(nil, nil), do: guess(Attributes.characters())
  def turn({:name_guessed?, false}, names), do: guess(names)

  def turn({:has_attribute?, has_attribute?}, {attribute, candidates}) do
    candidates
    |> Enum.filter(&(Attributes.character_has_attribute?(&1, attribute) == has_attribute?))
    |> guess()
  end

  defp guess([a, b, c]), do: {b, [a, c]}
  defp guess([a, b]), do: {b, [a]}
  defp guess([a]), do: {a, nil}

  defp guess(candidates) do
    Attributes.attributes()
    |> Enum.min_by(&distance_to_50(&1, candidates))
    |> then(&{&1, {&1, candidates}})
  end

  defp distance_to_50(attribute, candidates) do
    matches =
      candidates
      |> Enum.filter(&Attributes.character_has_attribute?(&1, attribute))
      |> Enum.count()

    abs(0.5 - matches / length(candidates))
  end
end
