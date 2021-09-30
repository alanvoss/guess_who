defmodule GuessWho.GameTest do
  use ExUnit.Case

  alias GuessWho.Game

  describe "new" do
    test "creates a new %Game{} struct" do
      contender = GuessWho.Contender.new(GuessWho.Contenders.Examples.BlueEyes)
      assert %Game{} = Game.new(contender, "Anne", [], outcome: :success)
    end
  end
end
