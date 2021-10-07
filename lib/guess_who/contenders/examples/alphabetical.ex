defmodule GuessWho.Contenders.Examples.Alphabetical do
  @moduledoc """
    This is sample contender Alphabetical.

    It gets all the characters that are possible, and guesses them
    in alphabetical order.

    Worst performance: 24 tries
    Median performance: 12 tries
  """

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "Alphabetical (Example Contender)"

  @impl GuessWho.Contender
  def turn(_response, state) do
    [first_character | rest] = remaining_characters(state)
    {first_character, rest}
  end

  defp remaining_characters(nil), do: Enum.sort(GuessWho.Attributes.characters())
  defp remaining_characters(characters), do: characters
end
