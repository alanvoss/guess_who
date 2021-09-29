defmodule GuessWho.AttributesTest do
  use ExUnit.Case

  alias GuessWho.Attributes

  describe "characters" do
    test "returns a list of all characters" do
      assert Enum.sort(Attributes.characters()) == Enum.sort(
        ["Alex", "Alfred", "Anita", "Anne", "Bernard", "Bill", "Charles", "Claire",
         "David", "Eric", "Frans", "George", "Herman", "Joe", "Maria", "Max", "Paul",
         "Peter", "Philip", "Richard", "Robert", "Sam", "Susan", "Tom"]
      )
    end
  end

  describe "attributes" do
    test "returns a list of all attributes" do
      assert Enum.sort(Attributes.attributes()) == Enum.sort(
        ["bald", "beard", "big mouth", "big nose", "black hair", "blond hair",
         "blonde hair", "blue eyes", "brown hair", "curly hair", "ear rings",
         "earrings", "female", "ginger hair", "glasses", "hair partition", "hair stuff",
         "hat", "long hair", "male", "moustache", "mustache", "red cheeks", "red hair",
         "sad looking", "white hair"]
      )
    end
  end

  describe "character_attributes" do
    test "when passed a valid character name, return all character attributes" do
      assert Enum.sort(Attributes.character_attributes("George")) == Enum.sort(
        ["hat", "hair stuff", "white hair", "big mouth", "sad looking", "male"]
      )
    end

    test "when passed an invalid character name, return empty list" do
      assert Attributes.character_attributes("Mary") == []
    end
  end

  describe "character_has_attribute?" do
    test "when passed a valid character name, check whether it has the attribute" do
      assert Attributes.character_has_attribute?("Alfred", "blue eyes")
      refute Attributes.character_has_attribute?("Philip", "blue eyes")
    end

    test "when passed an invalid character name, return false" do
      refute Attributes.character_has_attribute?("Alfredx", "blue eyes")
    end
  end

  describe "characters_with_attribute" do
    test "when passed a valid attribute name, return all characters with that attribute" do
      assert Attributes.characters_with_attribute("smelly") == []
      assert Attributes.characters_with_attribute("bald") == ["Bill", "Herman", "Richard", "Sam", "Tom"]
    end
  end

  describe "character_matches?" do
    test "if passed an invalid character name, return invalid" do
      assert Attributes.character_matches?("Peterx", "bald") == :invalid_character
    end

    test "when passed a regex for query, check that the name looks like the regex" do
      assert Attributes.character_matches?("Peter", ~r/^P/) == {:name_looks_like?, true}
      assert Attributes.character_matches?("Peter", ~r/^X/) == {:name_looks_like?, false}
    end

    test "when passed a query starting with a capital letter, assume it is a name guess" do
      assert Attributes.character_matches?("Peter", "Peter") == {:name_guessed?, true}
      assert Attributes.character_matches?("Peter", "Paul") == {:name_guessed?, false}
    end

    test "when passed a query starting with a lowercase letter, assume it is an attribute search" do
      assert Attributes.character_matches?("Peter", "hair partition") == {:has_attribute?, true}
      assert Attributes.character_matches?("Peter", "curly hair") == {:has_attribute?, false}
    end
  end
end
