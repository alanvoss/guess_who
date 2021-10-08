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

  # Final turn: We had two options last turn and guessed one of them - it was wrong - guess the other
  def turn({:name_guessed?, false}, name), do: {name, nil}

  # There are two options left - guess one of them and save the other one to guess next time
  defp guess([a, b]), do: {a, b}

  # There's only one option left - guess it
  defp guess([name]), do: {name, nil}

  # There's many options left - generate a regex that matches half of them and submit that
  defp guess(chars) do
    r = regex_matching_everything_in(half_list(chars))
    {r, {r, chars}}
  end

  defp regex_matching_everything_in(list), do: Regex.compile!("^(#{Enum.join(list, "|")})$")

  defp half_list(list), do: Enum.take(list, round(length(list) / 2))
end
