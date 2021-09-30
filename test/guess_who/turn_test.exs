defmodule GuessWho.TurnTest do
  use ExUnit.Case

  alias GuessWho.Turn

  describe "new" do
    test "creates a new %Turn{} struct" do
      assert %Turn{} = Turn.new("blue eyes", {:has_attribute?, true}, ["Alfred", "Bernard"])
    end
  end
end
