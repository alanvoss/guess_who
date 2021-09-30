defmodule GuessWho.Contender do
  @enforce_keys [:name, :module]
  defstruct name: nil, module: nil

  @type t() :: %__MODULE__{
          name: binary(),
          module: Atom.t()
        }

  @type state() :: any()

  # return a string that your module will be referred by in the tournament.
  #   NOTE: it should be deterministic and return the same thing across
  #         invocations.
  @callback name() :: binary()

  # given the query_response() to the previous character_query() and the
  # previously returned contender state(), return a new character_query() and
  # new state().
  #
  # your query_response() will be `nil` to start.
  # your state() will be `nil` to start.
  #
  # you will only receive a turn() callback if you haven't successfully
  # guessed the character yet.
  #
  # you will have a maximum of 50 guesses.
  #
  # in your state(), you should somehow represent your previous guesses.
  @callback turn(
              nil | GuessWho.Attributes.query_response(),
              nil | state()
            ) :: {GuessWho.Attributes.character_query(), state()}

  @spec new(Atom.t()) :: GuessWho.Contender.t()
  def new(module) do
    %__MODULE__{name: module.name(), module: module}
  end

  @spec all_player_modules() :: [Atom.t()]
  def all_player_modules() do
    {:ok, modules} = :application.get_key(:guess_who, :modules)

    Enum.filter(
      modules,
      &String.starts_with?(
        Atom.to_string(&1),
        "Elixir.GuessWho.Contenders"
      )
    )
  end
end
