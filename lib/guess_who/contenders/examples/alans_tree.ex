defmodule GuessWho.Contenders.Examples.AlansTree do
  @moduledoc """
  """

  alias GuessWho.Attributes
  @behaviour GuessWho.Contender

  @redundant_attributes ["male", "red hair", "blonde hair", "moustache", "ear rings"]
  # @start_attribute "big mouth"

  @impl GuessWho.Contender
  def name(), do: "Alan's Tree"

  #        bigmouth
  #       y (1)             n (1)
  #     X X X          X X X
  #  whitehair         bald

  @impl GuessWho.Contender
  def turn(nil, nil) do
    #IO.inspect(@tree)
    Attributes.characters()
    |> calculate_tree()

IO.puts("got here")

  #  find_next_query("fake_attribute", Attributes.characters())
  #  # {@start_attribute, {@start_attribute, Attributes.characters()}}
  end

  defp calculate_tree(characters) do
    calculate_tree(characters, 0, [])
  end

  defp calculate_tree(characters, depth, attribute_stack) do
    characters
    |> Enum.flat_map(&filtered_character_attributes(&1))
    |> Enum.reduce(%{}, fn attribute, acc -> Map.update(acc, attribute, 1, &(&1 + 1)) end)
    |> Enum.filter(&(elem(&1, 1) > 1))
    |> Map.new()
    |> Map.keys()
    |> Task.async_stream(fn attribute ->
         grouped_by_attributes =
           Enum.group_by(characters, fn character -> Attributes.character_has_attribute?(character, attribute) end)

         case grouped_by_attributes do
           %{true => have_attribute, false => dont_have_attribute} when length(have_attribute) > 1 and length(dont_have_attribute) > 1 ->
             {subtree_have, max_depth_have} = calculate_tree(have_attribute, depth + 1, attribute_stack ++ [attribute])
             {subtree_dont_have, max_depth_dont_have} = calculate_tree(dont_have_attribute, depth + 1, attribute_stack ++ [attribute])

             new_tree = %{attribute: %{{true, max_depth_have} => subtree_have, {false, max_depth_dont_have} => subtree_dont_have}}
             {new_tree, Enum.max([depth, max_depth_have, max_depth_dont_have])}
           _ ->
             {%{}, depth}
         end
       end)
     |> Enum.reduce({%{}, 0}, fn {subtree, depth}, {tree, max_depth} ->
IO.inspect(subtree)
          {Map.merge(tree, subtree), Enum.max([depth, max_depth])}
        end)

    # add a characters lineage


    # Map.put(acc, attribute, Enum.group_by(&Attributes.character_has_attribute?(&1, attribute)))



     # Map.update(acc, attribute, 1, &(&1 + 1)) end)




    #|> Map.delete(prev_attribute)
    #|> Enum.map(&{elem(&1, 0), Kernel.abs(half_count - elem(&1, 1))})
    #|> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
  end



  #def turn({_, false}, {<<first_letter::binary-size(1)>> <> _rest = name, remaining}) when first_letter >= "A" and first_letter <= "Z" do
  #  find_next_query(name, remaining -- [name])
  #end

  #def turn({_, true}, {attribute, _}) do
  #  find_next_query(attribute, Attributes.characters_with_attribute(attribute))
  #end

  #def turn({_, false}, {attribute, remaining}) do
  #  find_next_query(attribute, remaining -- Attributes.characters_with_attribute(attribute))
  #end

  #defp find_next_query(_, [character | rest] = remaining) when length(rest) <= 2 do
  #  IO.puts("characters that remain:")
  #  IO.inspect(remaining)
  #  IO.puts("about to guess #{character}")
  #  {character, {character, remaining}}
  #end


  ## at 6, 0, 6 no, 1, 5 no, 2, 4
  ## at 5, unless it is 3 and 2, it is best to just start guessing
  ## at 4, unless it is 2 and 2, it is best to just start guessing


  #defp find_next_query(prev_attribute, characters) do
  #  IO.puts("characters that remain:")
  #  IO.inspect(characters)

  #  half_count = 
  #    characters
  #    |> Enum.count()
  #    |> Integer.floor_div(2)

  #  IO.puts("half count: #{half_count}")

  #  attributes_sorted_by_closeness_to_half =
  #    characters
  #    |> Enum.flat_map(&Attributes.character_attributes(&1))
  #    |> Enum.reduce(%{}, fn attribute, acc -> Map.update(acc, attribute, 1, &(&1 + 1)) end)
  #    |> Map.delete(prev_attribute)
  #    |> Enum.map(&{elem(&1, 0), Kernel.abs(half_count - elem(&1, 1))})
  #    |> Enum.sort(&(elem(&1, 1) < elem(&2, 1)))
  #    |> IO.inspect()

  #  case List.last(attributes_sorted_by_closeness_to_half) do
  #    {_, x} when x in [0, 1] ->
  #      # can't differentiate by attribute, so just start guessing characters
  #      first_character = List.first(characters)
  #      IO.puts("about to guess #{first_character}")
  #      {first_character, {first_character, characters}}
  #    _ ->
  #      {new_attribute, _} = List.first(attributes_sorted_by_closeness_to_half)
  #      IO.puts("about to guess #{new_attribute}")
  #      {new_attribute, {new_attribute, characters}}
  #  end
  #end

  defp filtered_character_attributes(character) do
    character
    |> Attributes.character_attributes()
    |> Enum.filter(fn attribute ->
         attribute not in @redundant_attributes
       end)
  end
end
