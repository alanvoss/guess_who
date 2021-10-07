defmodule GuessWho.Contenders.Examples.BlueEyes do
  @moduledoc """
    This is sample contender Blue Eyes, the ever so slightly more intelligent
    example contender.

    It asks whether or not the character has blue eyes, and then it
    guesses all the blue eyed characters if so, and all the non-blue eyed
    characters if not.

    If the character has blue eyes (5 out of 24 characters):
    Worst performance: 1 (determination of blue eyes) + 5 (number of blue eyed characters) = 6 guesses
    Median performance: 1 (determination of blue eyes) + 3 (median number of blue eyed characters) = 4 guesses

    If the character doesn't have blue eyes (19 out of 24 characters):
    Worst performance: 1 (determination of not blue eyes) + 19 (number of non-blue eyed characters) = 20 guesses
    Median performance: 1 (determination of not blue eyes) + 10 (median number of non-blue eyed characters) = 11 guesses

    Overall:
    Worst performance: 20 guesses
    Median performance: 5/24 * 4 + 19/24 * 11 = 9.54 guesses
  """

  alias GuessWho.Attributes
  @behaviour GuessWho.Contender

  @my_pet_attribute "blue eyes"

  @impl GuessWho.Contender
  def name(), do: "Blue Eyes (Example Contender)"

  @impl GuessWho.Contender
  def turn(nil, nil) do
    {@my_pet_attribute, nil}
  end

  def turn(response, state) do
    [first | rest] = remaining_characters(response, state)
    {first, rest}
  end

  defp remaining_characters({:has_attribute?, true}, _) do
    Attributes.characters_with_attribute(@my_pet_attribute)
  end

  defp remaining_characters({:has_attribute?, false}, _) do
    Attributes.characters() -- Attributes.characters_with_attribute(@my_pet_attribute)
  end

  defp remaining_characters(_, characters) do
    characters
  end
end
