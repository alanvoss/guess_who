# GuessWho

Make a bot to compete against other bots while playing a variation of the classic "Guess Who"
game.

## How the Game is Played

Normally, two players play against each other.  There are 24 characters, each with a unique
name, and also facial features that are either unique to them, or a small group of them share.
Each player draws a card representing one of the characters, and keeps that card hidden.

The players then alternate attempting to either narrow down or guess the character that their
opponent has chosen and hidden.  They can narrow down by asking a question that has only a 
"yes" or "no" response.

For narrowing down or guessing a name, players can ask:

- a part of the name
  - "Does the character's name start with the letter 'S'?"
- a characteristic
  - "Does the character have blue eyes?"
  - "Does the character have a moustache?"
  - "Is the character female?"
- a character name

Players must wait until their following turn to guess a character's name, even if they have it
narrowed down to a single remaining character at the end of their turn.

The first to guess the name on the hidden card that their opponent holds is the winner.

[Video tutorial](https://www.youtube.com/watch?v=a76UPzU2VXM)

## Our Variation

Instead of 2 contenders playing against each other, you will be given an opportunity to try
to guess all 24 of the characters in the fewest possible queries, one at a time, and the
cumulative number of guesses will be used to score your contender.

Attempting to minimize that score as much as possible is the goal.

## Attributes

Look at [attributes.yaml](lib/guess_who/attributes.yaml).  The first indentation are
the groups of attributes.  ** DO NOT USE THOSE **  They are only there for navigating
through the file.

The second indentation in the file are the attributes that can be used.  Examples include:
- `big mouth`
- `sad looking`
- `male`

With the exception of `gender`, the characteristics are only listed for the minority group.
In other words, some characters have brown eyes, while others have blue, but since brown
eyes are the majority, and are least specific, only `blue eyes` are listed.  If you wanted
to get brown eyes, you would ask for `blue eyes`, and if you received an answer of
`{:has_attribute?, false}`, you'll know the eyes are brown.  This is to help you narrow
down your characters more quickly.

Under each attribute is a list of names that have that attribute.

Using functions in [GuessWho.Attributes](lib/guess_who/attributes.ex) will help you get
everything from a list of all characters and attributes, to all characters that have a
certain attribute.  Most of your bot coding will most likely use the helpers in this module.

## Bot Creation Instructions

- fork this repo: [Github GuessWho](https://github.com/alanvoss/connect_four)
  - On the top-right corner of the project page, click "Fork".
- create a contender
  - namespace: `GuessWho.Contenders.*`
  - in this directory [lib/guess_who/contenders/](lib/guess_who/contenders/)
- implement: `@behaviour GuessWho.Contender` (specifically `name/0` and `turn/2`)
  - `name/0` should return a unique and deterministic contender name
  - `turn/2` is the callback where you are given the previous query's `response` and `state`,
    and where you will return a tuple with a `query` and a new `state`.
    - your first argument `response` will be a tuple whose:
      - first element is one of:
        - `nil` on first turn 
        - `:name_looks_like?` for a previously-submitted name match query
        - `:has_attribute?` for a previous query as to whether a character has a certain attribute
        - NOTE: `:name_guessed?` will never be returned, as the engine uses that response
          internally to know when to end querying and record a score.
      - second element gives the engine response to that query type:
        - a boolean `true` or `false`
    - your second argument `state` is any information you passed from your previous turn.
    - example: `{:has_attribute?, true}`
    - you will then return a tuple whose:
      - first element `query` is one of:
        - an [attribute](lib/guess_who/attributes.yaml), such as `blue eyes` (binary)
        - a regex to match against the character's name, such as `~r/^A/`
        - a name guess (must include the capital letter), such as `Maria`
      - second element `state` is:
        - any state information you'd like passed back to you on the next turn
- you must guess a character name in 50 turns or less, otherwise you forfeit guessing that
  character.
- run `mix test` in the root directory of the project to make sure your bot passes some
  basic sanity testing.
- some mix tasks to help test your code (example usage using `mix help`):
  - dump out the total score (the sum of the number of guesses taken for each character) for a contender
    - `mix score --total <<contender module>>`
  - dump out the per-character scores turn logs for a contender
    - `mix score --per-character <<contender module>>`
  - dump out the individual game turn logs for a contender
    - `mix score --logs <<contender module>>`
  - dump out the individual game turn logs, the per-character scores, and the total score
    for a contender
    - `mix score <<contender module>>`
  - scores all contenders, including the example contenders
    - `mix score_all`
- commit your work locally and push to github
- submit a pull request by going to [GuessWho](https://github.com/alanvoss/guess_who) and
  finding the link at the top.
- have fun!

## Example Contenders

Check out [lib/guess_who/contenders/examples](lib/guess_who/contenders/examples/). 

## Extra Credit

Make an additional bot that does not use the regex functionality.
