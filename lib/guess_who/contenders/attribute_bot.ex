defmodule GuessWho.Contenders.AttributeBot do

  defmodule State do
    defstruct [
      characters: Enum.sort(GuessWho.Attributes.characters()),
      guessed: nil,
      guessed_attributes: []
    ]
  end

  alias GuessWho.Attributes
  alias __MODULE__.State

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "AttributeBot"

  @impl GuessWho.Contender
  def turn(response, state) do
    state =
      case state do
        nil -> %State{}
        _ -> %State{characters: remaining_characters(response, state)}
      end

    attr = attribute_for_characters(state.characters, state.guessed_attributes)

    new_state = %{state | guessed: attr,
                          guessed_attributes: state.guessed_attributes ++ [attr]}

    {attr, new_state}
  end

  defp remaining_characters({:has_attribute?, bool}, state) do
    filter_by_attribute(state.characters, state.guessed, bool)
  end

  # this response is only returned when guess was made with two names remaining
  defp remaining_characters({:name_guessed?, false}, state) do
    [_first, second] = state.characters
    [second]
  end

  defp attribute_for_characters(characters, _guessed_attributes) when length(characters) <= 2 do
    List.first(characters)
  end

  defp attribute_for_characters(characters, guessed_attributes) do
    attributes_by_count =
      characters
      |> Enum.flat_map(&Attributes.character_attributes/1)
      |> Enum.group_by(&(&1))
      |> Enum.reject(fn({attr, _c}) -> Enum.member?(guessed_attributes, attr) end)
      |> Enum.map(fn({attr, c}) -> {attr, Enum.count(c)} end)

    half =
      characters
      |> Enum.count()
      |> Kernel./(2)

    {attr, _count} =
      attributes_by_count
      |> Enum.map(fn({attr, count}) -> {attr, abs(count - half)} end)
      |> Enum.sort_by(fn({_attr, count}) -> count end)
      |> List.first()

    attr
  end

  defp filter_by_attribute(characters, attribute, has_attr) do
    characters_with_attr =
      characters
      |> Enum.map(fn(c) -> {c, Attributes.character_attributes(c)} end)
      |> Enum.filter(fn({_c, attrs}) -> Enum.member?(attrs, attribute) end)
      |> Enum.map(fn({c, _attr})-> c end)

    case has_attr do
      true -> characters_with_attr
      false -> characters -- characters_with_attr
    end
  end
end
