defmodule GuessWho.Contenders.Jordan0day do
  @moduledoc """
  Guess Who contender implementation for jordan.
  """

  # "male"'s not an aliased attribute, but don't need to guess male since we
  # start by guessing female.
  @aliases ["blond hair", "ear rings", "ginger hair", "moustache", "male"]

  @behaviour GuessWho.Contender

  # state
  # %{
  #   guesses: [string],
  #   responses: [bool],
  #   remaining_characters: [string]
  # }

  @impl GuessWho.Contender
  def name(), do: "jordan0day"

  @impl GuessWho.Contender
  # first turn
  @spec turn(any, any) :: {any, %{:remaining_characters => list, optional(any) => any}}
  def turn(nil, _state) do
    state = %{
      guesses: ["female"],
      responses: [],
      remaining_characters: GuessWho.Attributes.characters()
    }

    # narrow down by gender on first turn
    {"female", state}
  end

  def turn(_, %{remaining_characters: [char]} = state) do
    {char, state}
  end

  def turn({:name_guessed?, false}, %{guesses: [last_guess | _] = guesses, remaining_characters: chars} = state) do
    new_remaining_characters = List.delete(chars, last_guess)

    next_guess = List.first(new_remaining_characters)

    new_state = %{state | guesses: [next_guess | guesses], remaining_characters: new_remaining_characters}

    {next_guess, new_state}
  end

  # Subsequent turns
  def turn({:has_attribute?, result}, %{guesses: [last_guess | _] = guesses, responses: responses, remaining_characters: chars}) do
    new_remaining_characters = filter_characters(chars, last_guess, result)

    next_guess = select_next_guess(guesses, new_remaining_characters)

    new_state = %{
      guesses: [next_guess | guesses],
      responses: [result | responses],
      remaining_characters: new_remaining_characters
    }

    {next_guess, new_state}
  end

  defp all_attributes() do
    GuessWho.Attributes.attributes() -- @aliases
  end

  defp remaining_attributes(guesses) do
    all_attributes() -- guesses
  end

  defp filter_characters(chars, attribute, has_attribute?) do
    Enum.filter(chars, fn char_name ->
      GuessWho.Attributes.character_has_attribute?(char_name, attribute) == has_attribute?
    end)
  end

  # last resort...
  # defp select_next_guess(guesses, characters) do
  #   attrs = remaining_attributes(guesses)
  #   # If we've used up all the attributes, gotta just start guessing names
  #   if attrs == [] do
  #     List.first(characters)
  #   end

  #   Enum.random(attrs)
  # end

  defp select_next_guess(guesses, characters) do
    attrs = remaining_attributes(guesses)

    # If we've used up all the attributes, gotta just start guessing names
    if attrs == [] do
      List.first(characters)
    end

    # Otherwise, just pick the attribute with the most associated remaining characters.
    attrs
    |> Enum.map(fn attr ->
      matching = Enum.filter(characters, fn char ->
        GuessWho.Attributes.character_has_attribute?(char, attr)
      end)

      {attr, length(matching)}
    end)
    |> Enum.sort(fn {_, count1}, {_, count2} -> count1 >= count2 end)
    |> List.first()
    |> elem(0)
  end
end
