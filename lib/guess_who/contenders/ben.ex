defmodule GuessWho.Contenders.Ben do
  @moduledoc """
  A contender that binary searches by name and ignores all other attributes
  """

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "Ben"

  @impl GuessWho.Contender
  # Initial turn: Generate a guess from complete list of names
  def turn(nil, nil) do
    GuessWho.Attributes.characters()
    |> guess()
  end

  # Intermediate turns: generate a guess from the names that weren't ruled out by our regex last turn
  def turn({:name_looks_like?, did_match?}, {r, chars}) do
    chars
    |> Enum.filter(&(Regex.match?(r, &1) == did_match?))
    |> guess()
  end

  # Final turns: We had two or three options last turn and guessed one of them - it was wrong - guess another
  def turn({:name_guessed?, false}, {name, names}), do: guess(names -- [name])

  # Generate a regex that matches half of the remaining options and submit that
  # If "half" can be reasonably interpretted as a single name, directly guess that name instead of submitting a regex
  defp guess(chars) do
    r = regex_matching_everything_in(half_list(chars))
    {r, {r, chars}}
  end

  defp regex_matching_everything_in([name]), do: name
  defp regex_matching_everything_in(list), do: Regex.compile!("^(#{Enum.join(list, "|")})$")

  defp half_list([name]), do: [name]
  defp half_list(list), do: Enum.take(list, trunc(length(list) / 2))
end
