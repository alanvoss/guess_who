defmodule GuessWho.ContendersTest do
  use ExUnit.Case

  alias GuessWho.{Attributes, Contender}

  describe "callback implementations" do
    test "all contenders implement name() and return a binary" do
      for contender <- Contender.all_player_modules() do
        name = contender.name()
        assert is_binary(name)
      end
    end

    test "all contenders successfully initialize with call to turn(nil, nil)" do
      for contender <- Contender.all_player_modules() do
        # Just Awful gets a pass, as it is intentionally giving an incorrect query.
        if contender.name != "Just Awful (Example Contender)" do
          {query, _state} = contender.turn(nil, nil)

          sane_query =
            cond do
              is_struct(query, Regex) -> true
              query in Attributes.characters() -> true
              query in Attributes.attributes() -> true
              true -> false
            end

          assert sane_query
        end
      end
    end
  end
end
