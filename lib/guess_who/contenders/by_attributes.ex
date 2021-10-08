defmodule GuessWho.Contenders.ByAttributes do
  @behaviour GuessWho.Contender

  alias GuessWho.Attributes

  @impl true
  def name() do
    "JowensByAttributes"
  end

  @impl true

  def turn(nil, nil) do
    first = "male"

    state = %{
      remaining_characters: Attributes.characters(),
      attribute: first,
      guessed_attributes: []
    }

    {first, state}
  end

  def turn({:has_attribute?, false}, state) do
    attribute = state.attribute

    remaining_characters =
      Enum.reject(state.remaining_characters, &Attributes.character_has_attribute?(&1, attribute))

    guess(remaining_characters, state)
  end

  def turn({:has_attribute?, true}, state) do
    attribute = state.attribute

    remaining_characters =
      Enum.filter(state.remaining_characters, &Attributes.character_has_attribute?(&1, attribute))

    guess(remaining_characters, state)
  end

  def turn({:name_guessed?, false}, state) do
    [_bad_guess | rest] = state.remaining_characters

    guess(rest, state)
  end

  def guess([character], _state) do
    {character, nil}
  end

  def guess([character | _rest] = characters, state) do
    guessed_attributes = [state.attribute | state.guessed_attributes]

    attribute =
      character
      |> Attributes.character_attributes()
      |> Enum.find(&(&1 not in guessed_attributes))

    state = %{
      remaining_characters: characters,
      guessed_attributes: guessed_attributes,
      attribute: attribute
    }

    attribute =
      if attribute == nil do
        character
      else
        attribute
      end

    {attribute, state}
  end
end
