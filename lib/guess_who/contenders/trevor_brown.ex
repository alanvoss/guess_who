defmodule GuessWho.Contenders.TrevorBrown do
  @moduledoc """
  A strategy that finds the character by finding an attribute that splits the
  remaining characters into two groups of similar size in order to perform a
  binary search. Sometimes there is no attribute that splits the remaining
  characters 50/50, so this isn't a perfect strategy. Also lacks a few obivous
  optimizations.
  """
  alias GuessWho.Attributes
  @behaviour GuessWho.Contender

  # Based on a quick look in attributes.yml, big mouth seems to be a good first
  # question
  @my_pet_attribute "big mouth"

  @impl GuessWho.Contender
  def name(), do: "Trevor Brown"

  @impl GuessWho.Contender
  def turn(nil, nil) do
    {@my_pet_attribute, %{
      remaining_characters: Attributes.characters(),
      last_guess: @my_pet_attribute
    }}
  end

  def turn(response, %{remaining_characters: characters, last_guess: last_guess} = state) do
    case remaining_characters(response, characters, last_guess) do
      # We could have also had a case here for when two characters remain, and
      # rather than spliting on a character attribute we could have just taken
      # a guess of one character or the other.
      [name] ->
        {name, %{state | remaining_characters: [name]}}
      remaining ->
        guess = next_guess?(remaining)
        {guess, %{state | remaining_characters: remaining, last_guess: guess}}
    end
  end

  defp remaining_characters({:has_attribute?, true}, characters, last_guess) do
    # Feels like there should be an easier way to do this
    Enum.filter(characters, fn(character) ->
      Attributes.character_has_attribute?(character, last_guess)
    end)
  end

  defp remaining_characters({:has_attribute?, false}, characters, last_guess) do
    characters -- Attributes.characters_with_attribute(last_guess)
  end

  # Given a list of remaining characters by name, determine the best next guess
  defp next_guess?(remaining_characters) do
    # Ideally we want to find an attribute that splits the list exactly 50/50
    half = Enum.count(remaining_characters) / 2

    character_attrs =
      remaining_characters
      |> Enum.map(fn(character) ->
        {Attributes.character_attributes(character), character}
      end)

    attrs_list =
      character_attrs
      |> Enum.map(&elem(&1, 0))
      |> List.flatten()
      |> Enum.uniq()

    # This gets pretty messy and I'm sure there is a much better way of doing
    # this
    [{_, best_guess}|_possible_guesses] =
      attrs_list
      |> List.foldl([], fn(attribute, acc) ->
        count =
          character_attrs
          |> Enum.filter(fn({attrs, _name}) ->
            Enum.member?(attrs, attribute)
          end)
          |> Enum.count()

        [{abs(half - count), attribute}|acc]
      end)
      |> Enum.sort_by(fn({score, _attribute}) -> score end)

    best_guess
  end
end
