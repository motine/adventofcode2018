# This code is heavily inspired by the solution from https://github.com/sasa1977/aoc/blob/master/lib/2018/day9.ex
# My code is slightly less efficient due to the fact that I am using a list for scores and not a Map.
# Also, sasa1977 did a better job implementing the CircularList (because handles edge cases better).
defmodule CircularList do
  @moduledoc """
  A circular list is a tuple of previous elements and next elements
  We store the previous elements in reverse order, so we can next becomes a manipulation of the head only.
  Note from Kernek#++/2: The complexity of a ++ b is proportional to length(a), so avoid repeatedly appending to lists of arbitrary length, e.g. list ++ [element]. Instead, consider prepending via [element | rest] and then reversing.
  """  

  @doc """
  Creates a CircularList based on the elements given.
  """
  def new(elements), do: {[], elements}
  @doc "Creates a new CircularList using the given list for before (will be reversed internally) and after "
  def new(previous, rest), do: {Enum.reverse(previous), rest}

  @doc """
  Moves the list one forward.

  # Examples
      iex> next(new([1,2,3]))
      {[1], [2, 3]}
      iex> next(next(new([1,2,3])))
      {[2, 1], [3]}
      iex> next(next(next(new([1,2,3]))))
      {[], [1, 2, 3]}
  """
  def next({previous, [current | []]}), do: {[], Enum.reverse([current | previous])}
  def next({previous, [current | rest]}), do: {[current | previous], rest}

  @doc """
  Moves the list one back.

  # Examples
      iex> previous(new([1,2,3]))
      {[2, 1], [3]}
      iex> previous(previous(new([1,2,3])))
      {[1], [2, 3]}
      iex> previous(previous(previous(new([1,2,3]))))
      {[], [1, 2, 3]}
  """
  def previous({[], rest }), do: previous({ Enum.reverse(rest), [] })
  def previous({[current | previous], rest }), do: { previous, [current | rest] }

  def push({previous, rest}, value), do: {previous, [value | rest]}

  @doc """
  Returns the current element and the new CircularList as tuple.

  # Examples
      iex> pop(new([1,2,3]))
      {1, {[], [2,3]}}
      iex> pop(next(new([1,2,3])))
      {2, {[1], [3]}}
      iex> pop(next(next(new([1,2,3]))))
      {3, {[], [1, 2]}}
  """
  def pop({previous, [current | []]}), do: {current, {[], Enum.reverse(previous)}}
  def pop({previous, [current | rest]}), do: {current, {previous, rest}}

  def test do
  end
end

defmodule GameState do
  defstruct [:marbles, :scores]

  def play(player_count, last_marble) do
    Enum.reduce(1..last_marble, GameState.new(player_count), fn turn, state -> GameState.move(state, turn) end)
  end

  def new(player_count) do
    scores = for _ <- 1..player_count, do: 0
    %GameState{marbles: CircularList.new([0]), scores: scores}
  end

  def move(state, turn)

  def move(state, turn) when rem(turn, 23) == 0 do
    import CircularList
    {removed_marble, marbles} = pop(Enum.reduce(1..7, state.marbles, fn _, acc -> previous(acc) end))
    player_index = Integer.mod(turn, length(state.scores))
    player_score = Enum.at(state.scores, player_index) + turn + removed_marble # old score + current marble value + marble value of to remove
    %GameState{ state | marbles: marbles, scores: List.replace_at(state.scores, player_index, player_score) } # TODO score should be a map, because it is more efficient
  end

  def move(state, turn) do
    import CircularList
    marbles = push(next(next(state.marbles)), turn)
    %GameState{ state | marbles: marbles }
  end
end

GameState.play(416, 7197500).scores
  |> Enum.max
  |> IO.inspect

# => 3566801385
