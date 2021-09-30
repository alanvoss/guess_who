defmodule GuessWho.EngineTest do
  use ExUnit.Case

  alias GuessWho.{Engine, Game, Contender, Turn, Attributes}

  describe "start_game" do
    test "allows a maximum of 50 turns and :failure status, if so" do
      assert %Game{turns: turns, outcome: :failure} =
        Engine.start_game(GuessWho.Contenders.Examples.JustAwful, "Philip")

      assert length(turns) == 50
    end

    test "can accept a module for contender" do
      assert %Game{outcome: :success} =
        Engine.start_game(GuessWho.Contenders.Examples.BlueEyes, "Bernard")
    end

    test "can accept a %Contender{} for contender" do
      contender = Contender.new(GuessWho.Contenders.Examples.Random)
      character = "Joe"

      assert %Game{character: ^character} = Engine.start_game(contender, character)
    end

    test "if not fail, last turn should be the character guess and end in :success" do
      assert %Game{turns: turns, outcome: :success} =
        Engine.start_game(GuessWho.Contenders.Examples.Alphabetical, "Eric")

      assert %Turn{response: {:name_guessed?, true}} = List.last(turns)
    end
  end

  describe "match_contender_against_all_characters" do
    test "returns a %Game{} for each character" do
      assert games =
        Engine.match_contender_against_all_characters(GuessWho.Contenders.Examples.Alphabetical)

      assert length(games) == 24
      assert Enum.sort(Attributes.characters()) == Enum.sort(Enum.map(games, &(&1.character)))
    end
  end

  describe "score_contender" do
    test "returns 24 %Game{} structs, one for each character" do
      assert {game_logs, _, _} = Engine.score_contender(GuessWho.Contenders.Examples.Random)
      assert length(game_logs) == 24
      for game_log <- game_logs do
        assert %Game{} = game_log
      end
    end

    test "returns 24 scores, one for each character" do
      assert {_, per_character_score, _} = Engine.score_contender(GuessWho.Contenders.Examples.FirstLetter)

      scores = Map.values(per_character_score)
      assert length(scores) == 24
      assert Enum.min(scores) > 0
      assert Enum.max(scores) <= 50
    end

    test "returns a sum of all the scores for each character" do
      assert {_, _, total_score} = Engine.score_contender(GuessWho.Contenders.Examples.JustAwful)
      # everyone scores 50, the max number of turns, with JustAwful
      assert 50 * 24 == total_score
    end
  end

  describe "score_all_contenders" do
    test "returns one entry for each module in the GuessWho.Contenders* namespace" do
      number_of_modules = length(Contender.all_player_modules())
      scores = Engine.score_all_contenders()
      assert length(scores) == number_of_modules
    end

    # yes, this is testing for naming clashes, really.
    test "returns unique names" do
      number_of_modules = length(Contender.all_player_modules())

      unique_names =
        Engine.score_all_contenders()
        |> Enum.map(&(elem(&1, 0)))
        |> Enum.uniq()

      assert length(unique_names) == number_of_modules
    end

    test "returns scores that are all greater than 0 and less than 50 * 24 (1200)" do
      scores = Enum.map(Engine.score_all_contenders(), &(elem(&1, 1)))
      assert Enum.all?(scores, fn score -> score > 0 && score <= 1200 end)
    end
  end
end
