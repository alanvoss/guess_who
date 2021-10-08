defmodule GuessWho.Attributes do
  @attributes_config_file "lib/guess_who/attributes.yaml"
  # e.g. "Alfred", see bottom-level list values of @attributes_config_file
  @type character() :: binary()

  # e.g. "red cheeks", ignoring higher-level groupings (which are ignored by
  # this module, and only used to make browsing potentially faster in the YAML
  # itself), see parent keys of the characters in the @attributes_config_file
  @type attribute() :: binary()

  @type character_query() :: Regex.t() | character() | attribute()
  @type query_response_type() :: :name_looks_like? | :name_guessed? | :has_attribute?
  @type query_response() :: {query_response_type(), boolean()} | :invalid_character

  {:ok, config} =
    File.cwd!()
    |> Path.join(@attributes_config_file)
    |> YamlElixir.read_from_file()

  @attribute_characters config
                        |> Map.values()
                        |> Enum.reduce(%{}, &Map.merge(&1, &2))

  @character_attributes Enum.reduce(@attribute_characters, %{}, fn {attribute, characters}, acc ->
                          Enum.reduce(characters, acc, fn character, acc ->
                            Map.update(acc, character, [attribute], &(&1 ++ [attribute]))
                          end)
                        end)

  @character_attribute_lookup Enum.reduce(@character_attributes, %{}, fn {character, attributes},
                                                                         acc ->
                                lookup =
                                  attributes
                                  |> Enum.map(&{&1, true})
                                  |> Map.new()

                                Map.put(acc, character, lookup)
                              end)

  @spec characters() :: [character()]
  def characters() do
    Map.keys(@character_attributes)
  end

  @spec attributes() :: [attribute()]
  def attributes() do
    Map.keys(@attribute_characters)
  end

  @spec character_attributes(character()) :: [attribute()]
  def character_attributes(character) do
    Map.get(@character_attributes, character, [])
  end

  @spec character_has_attribute?(character(), attribute()) :: boolean()
  def character_has_attribute?(character, attribute) do
    get_in(@character_attribute_lookup, [character, attribute]) || false
  end

  @spec characters_with_attribute(attribute()) :: [character()]
  def characters_with_attribute(attribute) do
    Map.get(@attribute_characters, attribute, [])
  end

  @spec character_matches?(character(), character_query()) :: query_response()
  def character_matches?(character, query) do
    if Map.has_key?(@character_attributes, character) do
      matches?(character, query)
    else
      :invalid_character
    end
  end

  defp matches?(character, %Regex{} = query) do
    {:name_looks_like?, Regex.match?(query, character)}
  end

  defp matches?(character, <<first_letter::binary-size(1)>> <> _rest = query)
       when first_letter >= "A" and first_letter <= "Z" do
    {:name_guessed?, character == query}
  end

  defp matches?(character, query) do
    {:has_attribute?, character_has_attribute?(character, query)}
  end
end
