defmodule GuessWho.Engine do
  alias GuessWho.{Contender, Attributes, Game, Turn}

  @max_turns 50

  @spec score_all_contenders() :: [{binary(), Integer.t()}]
  def score_all_contenders() do
    modules = Contender.all_player_modules()

    names = Enum.map(modules, &(&1.name))

    scores =
      modules
      |> Enum.map(&score_contender/1)
      |> Enum.map(fn {_, _, total_score} -> total_score end)

    Enum.zip(names, scores)
  end

  @spec score_contender(Contender.t() | Atom.t()) :: {[Game.t()], %{Attribute.character() => Integer.t()}, Integer.t()}
  def score_contender(contender) do
    contender = get_contender_if_module(contender)
    game_logs = match_contender_against_all_characters(contender)

    per_character_score =
      game_logs
      |> Enum.map(&{&1.character, length(&1.turns)})
      |> Map.new()

    total_score =
      per_character_score
      |> Map.values()
      |> Enum.sum()

    {game_logs, per_character_score, total_score}
  end

  @spec match_contender_against_all_characters(Contender.t() | Atom.t()) :: [Game.t()]
  def match_contender_against_all_characters(contender) do
    contender = get_contender_if_module(contender)
    Enum.map(Attributes.characters(), &start_game(contender, &1))
  end

  @spec start_game(Contender.t() | Atom.t(), Attributes.character()) :: Game.t()
  def start_game(contender, character) do
    contender = get_contender_if_module(contender)
    {outcome, turns} = do_turns(contender, character, [], 0)
    Game.new(contender, character, Enum.reverse(turns), outcome)
  end

  defp do_turns(_, _, [%Turn{response: {:name_guessed?, true}} | _] = turns, _) do
    {:success, turns}
  end

  defp do_turns(_, _, turns, @max_turns) do
    {:failure, turns}
  end

  defp do_turns(contender, character, turns, count) do
    turn_arguments =
      case turns do
        [] -> [nil, nil]
        [%Turn{response: response, state: state} | _] -> [response, state]
      end

    {query, state} = apply(contender.module, :turn, turn_arguments)
    response = Attributes.character_matches?(character, query)
    do_turns(contender, character, [Turn.new(query, response, state) | turns], count + 1)
  end

  defp get_contender_if_module(%Contender{} = contender), do: contender
  defp get_contender_if_module(contender), do: Contender.new(contender)
end
