defmodule GuessWho.Turn do
  @enforce_keys [:query, :response, :state]
  defstruct query: nil, response: nil, state: nil

  alias GuessWho.Attributes

  @type t(query, response, state) :: %__MODULE__{query: query, response: response, state: state}
  @type t :: %__MODULE__{
          query: Attributes.character_query(),
          response: Attributes.query_response(),
          state: any()
        }

  @spec new(Attributes.character_query(), Attributes.query_response(), any()) :: t()
  def new(query, response, state) do
    %__MODULE__{query: query, response: response, state: state}
  end
end
