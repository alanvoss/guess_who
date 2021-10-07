defmodule Mix.Tasks.Score do
  @moduledoc """
  Score a single contender.

  Example usage:
    `mix score --total GuessWho.Contenders.Examples.BlueEyes`
    `mix score --per-character GuessWho.Contenders.Examples.Random`
    `mix score --logs GuessWho.Contenders.Examples.FiveLetters`
    `mix score GuessWho.Contenders.Examples.Alphabetical`
  """

  @shortdoc "Score a contender"

  use Mix.Task

  @impl Mix.Task
  def run(["--total", module]) do
    {_, _, total_score} = score_contender(module)
    total(total_score)
  end

  def run(["--per-character", module]) do
    {_, per_character_score, total_score} = score_contender(module)
    IO.inspect(per_character_score)
    total(total_score)
  end

  def run(["--logs", module]) do
    {game_logs, _, _} = score_contender(module)
    IO.inspect(game_logs)
  end

  def run([module]) do
    module
    |> score_contender()
    |> IO.inspect()
  end

  def run([]) do
    IO.puts(@moduledoc)
  end

  defp score_contender(module) do
    GuessWho.Engine.score_contender(module)
  end

  defp total(total_score) do
    IO.puts("\nTotal score: #{total_score}")
  end
end
