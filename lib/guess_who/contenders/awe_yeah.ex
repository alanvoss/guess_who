defmodule GuessWho.Contenders.AweYeah do
  @behaviour GuessWho.Contender
  alias GuessWho.Attributes

  def name do
    "Awe Yeah #{System.unique_integer([:positive])}"
  end

  def turn(nil, nil) do
    attributes = Attributes.attributes()
    characters = Attributes.characters()
    attribute_guess = pick_attribute(attributes, characters)
    {attribute_guess, {attribute_guess, attributes -- [attribute_guess], characters}}
  end

  def turn(_, {_, _, [name]} = state) do
    {name, state}
  end

  def turn(
        {:has_attribute?, response},
        {last_attribute, attributes_remaining, characters_remaining}
      ) do
    chars_remaining = remaining_characters(response, last_attribute, characters_remaining)
    attribute_guess = pick_attribute(attributes_remaining, chars_remaining)
    {attribute_guess, {attribute_guess, attributes_remaining -- [attribute_guess], chars_remaining}}
  end

  defp remaining_characters(true, attr, characters) do
    chars_without = characters -- Attributes.characters_with_attribute(attr)
    characters -- chars_without
  end

  defp remaining_characters(false, attr, characters) do
    characters -- Attributes.characters_with_attribute(attr)
  end

  def pick_attribute(attributes_remaining, characters_remaining) do
    attribute_map =
      for character <- characters_remaining,
          attribute <- attributes_remaining,
          Attributes.character_has_attribute?(character, attribute),
          reduce: Map.new(attributes_remaining, fn key -> {key, 0} end) do
        attribute_counts -> Map.update(attribute_counts, attribute, 1, &(&1 + 1))
      end

      {attr, _} = Enum.sort_by(attribute_map, fn {_, count} -> count end, :desc)
      |> Enum.filter(&{match?({_,0}, &1)})
      |> List.first()
      attr
  end
end
