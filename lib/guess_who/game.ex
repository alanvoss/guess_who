defmodule GuessWho.Game do
  @enforce_keys [:contender, :character, :turns, :outcome]
  defstruct contender: nil, character: nil, turns: nil, outcome: nil

  alias GuessWho.Attributes

  @type outcome() :: :success | :failure

  @type t(contender, character, turns, outcome) :: %__MODULE__{
          contender: contender,
          character: character,
          turns: turns,
          outcome: outcome
        }
  @type t :: %__MODULE__{
          contender: %GuessWho.Contender{},
          character: Attributes.character(),
          turns: [GuessWho.Turn.t()],
          outcome: outcome()
        }

  @spec new(
          GuesWho.Contender.t(),
          GuessWho.Attributes.character(),
          [GuessWho.Turn.t()],
          outcome()
        ) :: t()
  def new(contender, character, turns, outcome) do
    %__MODULE__{contender: contender, character: character, turns: turns, outcome: outcome}
  end
end
