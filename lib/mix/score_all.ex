defmodule Mix.Tasks.ScoreAll do
  @moduledoc """
  Scores all contenders and outputs results.

  `mix score_all`
  """
  @shortdoc "Scores contenders"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    IO.inspect(GuessWho.Engine.score_all_contenders())
  end
end
