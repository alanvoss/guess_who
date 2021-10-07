defmodule GuessWho.Contenders.Examples.FiveLetters do
  @moduledoc """
    This is sample contender Five Letters, another ever so slightly more intelligent
    example contender.

    It asks whether or not the character has 5 or more letters in their name.

    If the character has five or more letters (15 out of 24 characters):
    Worst performance: 1 (determination of five or more letters) + 15 (number of characters with five or more letters) = 16 guesses
    Average performance: 1 (determination of five or more letters) + 8 (median number of characters with five or more letters) = 9 guesses

    If the character has fewer than five letters (9 out of 24 characters):
    Worst performance: 1 (determination of fewer than five letters) + 9 (number of characters with fewer than five letters) = 16 guesses
    Average performance: 1 (determination of fewer than five letters) + 5 (median number of characters with fewer than five letters) = 6 guesses

    Overall:
    Worst performance: 16 guesses
    Average performance: 15/24 * 9 + 9/24 * 6 = 7.875
  """

  alias GuessWho.Attributes
  @behaviour GuessWho.Contender

  @five_char_regex ~r/^\w{5,}$/

  @impl GuessWho.Contender
  def name(), do: "Five Letters (Example Contender)"

  @impl GuessWho.Contender
  def turn(nil, nil) do
    {@five_char_regex, nil}
  end

  @impl GuessWho.Contender
  def turn(response, state) do
    [first | rest] = remaining_characters(response, state)
    {first, rest}
  end

  defp remaining_characters({:name_looks_like?, true}, _) do
    Enum.filter(
      Attributes.characters(),
      &(Regex.match?(@five_char_regex, &1))
    )
  end

  defp remaining_characters({:name_looks_like?, false}, _) do
    Enum.filter(
      Attributes.characters(),
      &(!Regex.match?(@five_char_regex, &1))
    )
  end

  defp remaining_characters(_, characters) do
    characters
  end
end
