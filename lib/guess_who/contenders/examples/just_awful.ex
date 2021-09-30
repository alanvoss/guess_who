defmodule GuessWho.Contenders.Examples.JustAwful do
  @moduledoc """
    This is sample contender Just Awful.

    It only guesses characters that don't exist.  It is here simply to test
    that 50 turns are the max that any contender can take.

    Worst performance: 50 tries
    Average performance: 50 tries
  """

  @behaviour GuessWho.Contender

  @impl GuessWho.Contender
  def name(), do: "Just Awful (Example Contender)"

  @impl GuessWho.Contender
  def turn(_response, _state) do
    {"Alan", nil}
  end
end
