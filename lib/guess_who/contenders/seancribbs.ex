defmodule GuessWho.Contenders.Seancribbs do
  @behaviour GuessWho.Contender

  def name do
    "Sean's Guesstimator"
  end

  # Post result, need an algorithm to eliminate characters and attributes excluded

  defmodule State do
    defstruct guesses: [],
              characters:
                GuessWho.Attributes.characters()
                |> Enum.map(&{&1, GuessWho.Attributes.character_attributes(&1)})
                |> Map.new(),
              attributes:
                GuessWho.Attributes.attributes()
                |> Enum.map(&{&1, GuessWho.Attributes.characters_with_attribute(&1)})
                |> Map.new()

    def cleanup({:has_attribute?, result}, %{guesses: [attribute | _]} = state) do
      suspects = GuessWho.Attributes.characters_with_attribute(attribute)

      chars =
        if result do
          Map.take(state.characters, suspects)
        else
          Map.drop(state.characters, suspects)
        end

      %{state | characters: chars, attributes: Map.delete(state.attributes, attribute)}
    end

    def cleanup({:name_looks_like?, result}, %{guesses: [pattern | _]} = state) do
      suspects =
        state.characters
        |> Map.keys()
        |> Enum.filter(fn c ->
          {_, test} = GuessWho.Attributes.character_matches?(c, pattern)
          result == test
        end)

      new_chars =
        if result do
          Map.take(state.characters, suspects)
        else
          Map.drop(state.characters, suspects)
        end

      new_attributes =
        if result do
          # If the name does match, we only care about the attributes that are
          # associated with those characters
          keep =
            new_chars
            |> Map.values()
            |> List.flatten()
            |> Enum.uniq()

          state.attributes
          |> Map.take(keep)
          |> Enum.map(fn {a, cs} -> {a, Enum.filter(cs, &(&1 in suspects))} end)
          |> Map.new()
        else
          state.attributes
          |> Enum.map(fn {a, cs} -> {a, Enum.reject(cs, &(&1 in suspects))} end)
          |> Enum.reject(fn {_a, cs} -> cs == [] end)
          |> Map.new()
        end

      %{state | characters: new_chars, attributes: new_attributes}
    end

    def cleanup({:name_guessed?, false}, %{guesses: [name | _]} = state) do
      new_chars = Map.delete(state.characters, name)

      %{
        state
        | characters: new_chars,
          attributes:
            state.attributes
            |> Enum.map(fn {a, cs} -> {a, cs -- [name]} end)
            |> Enum.reject(fn {_a, cs} -> cs == [] end)
            |> Map.new()
      }
    end
  end

  def turn(nil, nil) do
    # always guess male/female first
    {"male", %State{guesses: ["male"]}}
  end

  def turn(result, state) do
    state = State.cleanup(result, state)

    cond do
      Enum.count(state.characters) == 1 ->
        # It's this dude(tte)
        char = hd(Map.keys(state.characters))
        {char, %{state | guesses: [char | state.guesses]}}

      Enum.count(state.attributes) == 1 ->
        # Fallback to linear guessing because I can't be arsed to build a trie
        char = hd(hd(Map.values(state.attributes)))
        {char, %{state | guesses: [char | state.guesses]}}

      true ->
        # Find the largest attribute to partition on, hopefully eliminating or
        # selecting the largest group
        {attr, _} = Enum.max_by(state.attributes, fn {_a, cs} -> Enum.count(cs) end)
        {attr, %{state | guesses: [attr | state.guesses]}}
    end
  end
end
