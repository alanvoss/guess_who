defmodule GuessWho.Contenders.SplitBot do
  @moduledoc """
  Splits the list of names in half and builds a
  regex to essentially binary sort the names.
  """

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "SplitBot"

  @impl GuessWho.Contender
  def turn(response, state) do
    names = remaining_characters(response, state)

    {first_half, _second_half} = split_list(names)

    {build_guess(first_half), names}
  end

  # if its a single name, guess that name
  # otherwise split in half and build the regex
  defp build_guess(names) do
    case names do
      [name] -> name
      [_first | _rest] -> build_regex(names)
    end
  end

  defp build_regex(names) do
    {:ok, regex} =
      names
      |> Enum.join("|")
      |> Regex.compile()

    regex
  end

  defp remaining_characters(nil, nil), do: Enum.sort(GuessWho.Attributes.characters())

  defp remaining_characters({:name_looks_like?, true}, state) do
    {first_half, _second_half} = split_list(state)
    first_half
  end

  defp remaining_characters({:name_looks_like?, false}, state) do
    {_first_half, second_half} = split_list(state)
    second_half
  end

  defp remaining_characters({:name_guessed?, false}, state) do
    [_first | rest] = state
    rest
  end

  # Enum.split/2 returns the empty list first and I wanted the empty one last
  defp split_list([name]), do: {[name], []}
  defp split_list(names) do
    half =
      names
      |> Enum.count()
      |> Kernel./(2)
      |> Float.floor()
      |> Kernel.trunc()

    Enum.split(names, half)
  end
end
