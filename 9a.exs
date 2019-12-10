defmodule GameState do
  @doc """
  Represents a game state.

  - `marbles` represents the marbles as a list (items represent the value of the marble).
  - `scores` contains the list of player scores (first item is player 1, second player 2, ...). The length of this list implicitly defines the number of players
  """
  defstruct marbles: [0], scores: [0, 0, 0], marble_index: 0

  def play(player_count, last_marble) do
    Enum.reduce(1..last_marble, GameState.initial_struct(player_count), fn turn, state -> GameState.move(state, turn) end)
  end

  @doc "Returns the initial GameState for the given variables"
  def initial_struct(player_count) do
    scores = for _ <- 1..player_count, do: 0
    %GameState{marbles: [0], scores: scores, marble_index: 0}
  end

  @doc """
  - `marble` is the value of the next marble to play.
  - `turn` is the index of the current turn (1-based, determines the player and the number to insert).

  ## Examples

      iex> %GameState{ marbles: [0, 1], marble_index: 1 } = GameState.move(%GameState{marbles: [0], scores: [0, 0, 0], marble_index: 0 }, 1)
      iex> %GameState{ marbles: [0, 2, 1], marble_index: 1 } = GameState.move(%GameState{marbles: [0, 1], scores: [0, 0, 0], marble_index: 1 }, 2)
      iex> %GameState{ marbles: [0, 2, 1, 3], marble_index: 3 } = GameState.move(%GameState{marbles: [0, 2, 1], scores: [0, 0, 0], marble_index: 1}, 3)
      iex> %GameState{ marbles: [0, 4, 2, 1, 3], marble_index: 1 } = GameState.move(%GameState{marbles: [0, 2, 1, 3], scores: [0, 0, 0], marble_index: 3}, 4)
      iex> %GameState{ marbles: [0, 16, 8, 17, 4, 18, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15], marble_index: 6, scores: [0, 0, 32]} = GameState.move(%GameState{marbles: [0,16,8,17,4,18,9,19,2,20,10,21,5,22,11,1,12,6,13,3,14,7,15], marble_index: 13}, 23)
  """
  def move(state, turn)

  def move(state, turn) when rem(turn, 23) == 0 do
    player_index = Integer.mod(turn, length(state.scores))
    remove_index = Integer.mod(state.marble_index - 7, length(state.marbles))
    player_score = Enum.at(state.scores, player_index) + turn + Enum.at(state.marbles, remove_index) # old score + current marble value + marble value of to remove
    %GameState{ state | marbles: List.delete_at(state.marbles, remove_index), marble_index: remove_index, scores: List.replace_at(state.scores, player_index, player_score) }
  end

  def move(state, turn) do
    insert_index = Integer.mod(state.marble_index + 1, length(state.marbles)) + 1 # make sure that if we want to append at the end, we use the length of marbles as index
    %GameState{ state | marbles: List.insert_at(state.marbles, insert_index, turn), marble_index: insert_index }
  end
end


GameState.play(416, 71975).scores
  |> Enum.max
  |> IO.inspect

# a) => 439341
# b) => ???


# side notes
# [-] (0)
# [1]  0 (1)
# [2]  0 (2) 1 
# [3]  0  2  1 (3)
# [4]  0 (4) 2  1  3 
# [5]  0  4  2 (5) 1  3 
# [6]  0  4  2  5  1 (6) 3 
# [7]  0  4  2  5  1  6  3 (7)
# [8]  0 (8) 4  2  5  1  6  3  7 

# mi+2 | %c || count | marble_index || insertion | result_marble_index
# 2    |    || 1     | 0            || 1         | 1
# 3    | 1  || 2     | 1            || 1         | 1
# 3    | 0  || 3     | 1            || 3         | 3
# 5    | 1  || 4     | 3            || 1         | 1
# 3    | 3  || 5     | 1            || 3         | 3
# 5    | 5  || 6     | 3            || 5         | 5
# 7    | 7  || 7     | 5            || 7         | 7
# 9    | 1  || 8     | 7            || 1         | 1