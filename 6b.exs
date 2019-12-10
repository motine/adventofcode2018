defmodule Coordinate do
  defstruct [:x, :y]

  @doc ~S"""
  Returns Manhattan distance between the two coordinates.

  ## Examples

      iex> Coordinate.distance(%Coordinate{x: 1, y: 2}, %Coordinate{x: 3, y: 1})
      3
  """
  def distance(coordinate_a, coordinate_b) do
    abs(coordinate_a.x - coordinate_b.x) + abs(coordinate_a.y - coordinate_b.y)
  end

  @doc "Returns a new coordinate with the highest x value found in the coordinate (y value respectively)"
  def max_coordinate(locations) do
    Enum.reduce(locations, %Coordinate{x: 0, y: 0}, fn coordinate, acc -> 
        %Coordinate{x: max(coordinate.x, acc.x), y: max(coordinate.y, acc.y)}
      end)
  end

  @doc ~S"""
  Returns a list of all possible coordinates in from (left_top.x, left_top.y) to (right_bottom.x, right_bottom.y)

  ## Examples

      iex> Coordinate.all_in(%Coordinate{x: 0, y: 0}, %Coordinate{x: 2, y: 3})
      [ %Coordinate{x: 0, y: 0}, %Coordinate{x: 0, y: 1}, %Coordinate{x: 0, y: 2}, %Coordinate{x: 0, y: 3}, %Coordinate{x: 1, y: 0}, %Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 2}, %Coordinate{x: 1, y: 3}, %Coordinate{x: 2, y: 0}, %Coordinate{x: 2, y: 1}, %Coordinate{x: 2, y: 2}, %Coordinate{x: 2, y: 3}]
  """
  def all_in(left_top, right_bottom) do
    for x <- left_top.x..right_bottom.x, y <- left_top.y..right_bottom.y, do: %Coordinate{x: x, y: y}
  end

  @doc ~S"""
  Sums up the distances from all locations to the given coordinate.

  ## Examples
  
  The examples below are based on the task description on [Day 6, part 2](https://adventofcode.com/2018/day/6#part2).

      iex> Coordinate.distance_sum(%Coordinate{x: 4, y: 3}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      30
  """
  def distance_sum(coordinate, locations) do
    Enum.reduce(locations, 0, fn location, sum -> sum + Coordinate.distance(coordinate, location) end)
  end

  # Approach
  # find max dimensions
  # iterate through a grid (linked list) which is 1000 x 1000 larger
  #   filter the item if the sum of all distances is smaller than 10000
  # print the length of the list
  def main do
    locations = File.read!("6.txt")
      |> String.split("\n")
      |> Enum.map(fn line -> [x, y] = String.split(line, ", "); %Coordinate{x: String.to_integer(x), y: String.to_integer(y)} end)

    
    Coordinate.all_in(%Coordinate{ x: 0, y: 0}, Coordinate.max_coordinate(locations))
      |> Enum.filter(fn coordinate -> Coordinate.distance_sum(coordinate, locations) < 10000 end)
      |> length
  end
end

IO.inspect(Coordinate.main)

# => 40284
