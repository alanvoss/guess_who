defmodule GuessWho.Contenders.Examples.Random do
  @moduledoc """
    This is sample contender Random.

    It gets all the characters that are possible, and guesses them
    in random order.

    Worst performance: 24 tries
    Average performance: 12 tries
  """

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "Random (Example Contender)"

  @impl GuessWho.Contender
  def turn(_response, state) do
    characters = remaining_characters(state)
    next_guess = Enum.random(characters)

    {next_guess, characters -- [next_guess]}
  end

  defp remaining_characters(nil), do: GuessWho.Attributes.characters()
  defp remaining_characters(characters), do: characters
end
