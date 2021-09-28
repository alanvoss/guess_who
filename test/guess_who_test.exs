defmodule GuessWhoTest do
  use ExUnit.Case
  doctest GuessWho

  test "greets the world" do
    assert GuessWho.hello() == :world
  end
end
