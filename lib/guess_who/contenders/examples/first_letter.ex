defmodule GuessWho.Contenders.Examples.FirstLetter do
  @moduledoc """
    This is sample contender First Letter, another ever so slightly more intelligent
    example contender.

    It asks whether or not the first letter of the character name is A-G, and then
    it guesses all of the characters that start with A-G or H-Z, which is about half.

    Worst performance: 1 (determination of A-G) + 12 (number of characters in that A-G or H-Z section) = 13 guesses
    Average performance: 1 (determination of A-G) + 6 (half the number of characters in that A-G or H-Z section) = 7 guesses
  """

  alias GuessWho.Attributes
  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "First Letter (Example Contender)"

  @impl GuessWho.Contender
  def turn(nil, nil) do
    {~r/^[A-G]/, nil}
  end

  @impl GuessWho.Contender
  def turn(response, state) do
    [first | rest] = remaining_characters(response, state)
    {first, rest}
  end

  defp remaining_characters({:name_looks_like?, true}, _) do
    Enum.filter(
      Attributes.characters(),
      &(Regex.match?(~r/^[A-G]/, &1))
    )
  end

  defp remaining_characters({:name_looks_like?, false}, _) do
    Enum.filter(
      Attributes.characters(),
      &(Regex.match?(~r/^[H-Z]/, &1))
    )
  end

  defp remaining_characters(_, characters) do
    characters
  end
end
