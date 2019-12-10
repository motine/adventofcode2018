# using protocols here is not really smart, but I wanted to try this out...
defprotocol TwoDimensionMax do
  @doc "Retrieves the maximum index of a two dimensional list structure (e.g. [[1,2,3], [4,5,6], [7,8,9]]"
  def max_with_index(data)
  @doc "Retrieves the maximum index of a two dimensional list structure (e.g. [[1,2,3], [4,5,6], [7,8,9]]"
  def two_dimensional_max_with_index(data)
end

defimpl TwoDimensionMax, for: List do

  def max_with_index(list) do
    list
    |> Enum.with_index
    |> Enum.reduce({0, 0}, fn {value, index}, {max_value, max_index} ->
      if (value > max_value) do
        {value, index}
      else
        {max_value, max_index}
      end
    end)
  end

  @doc """
  Returns the coordinate and the value of the maximum of a two-dimensional list (e.g. { {2,3}, 77 } => the maximum of 77 is found in the second column, third row)

  **Limitation** we currently assume that the maximum value is > 0.
  """
  def two_dimensional_max_with_index(list) do
    # reduce list's first dimension with accumulator {{max_x_index, max_y_index}, max_value} (find max of the all row maxes)
      # reduce list's second dimension (find the max of the row)
    list
    |> Enum.with_index
    |> Enum.reduce({ {0,0}, 0}, fn {current_row, current_row_index}, { {max_x_index, max_y_index}, max_value } ->
      {row_max_value, row_max_index} = TwoDimensionMax.max_with_index(current_row)
      if row_max_value > max_value do # we found a bigger value in the row, so we pass this one on
        { {row_max_index, current_row_index}, row_max_value }
      else # no bigger value, so we pass on the accumulator
        { {max_x_index, max_y_index}, max_value }
      end
    end)
  end
end

defmodule FuelCell do
  @doc """
  Calculates the power level for a given coordinate & serial.

  ## Example
      iex> power_level(3,5,8)
      4
      iex> power_level(122,79,57)
      -5
      iex> power_level(217,196,39)
      0
      iex> power_level(101,153,71)
      4
  """
  def power_level(x, y, grid_serial) do
    rack_id = x + 10 # Find the fuel cell's rack ID, which is its X coordinate plus 10.
    power_level = rack_id * y # Begin with a power level of the rack ID times the Y coordinate.
    power_level = power_level + grid_serial  # Increase the power level by the value of the grid serial number (your puzzle input).
    power_level = power_level * rack_id # Set the power level to itself multiplied by the rack ID.
    power_level = rem(div(power_level, 100), 10)# Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
    power_level - 5 # Subtract 5 from the power level.
  end

  @doc "Returns a map of coordinates to power_levels."
  def power_grid(x_range, y_range, grid_serial) do
    coordinates = for y <- y_range, x <- x_range, do: {x, y}
    Enum.reduce(coordinates, %{}, fn {x, y}, acc -> Map.put(acc, {x,y}, power_level(x,y, grid_serial)) end)
  end

  @doc """
  Returns a two dimensional list. Each item is the sum of the 8-neighbors sum.
  
  ### Examples

  This example has the values of a 3x3 grid as input. Then we build the sum of exactly one point in the grid (1,1).
  Careful, this example is 0-based, where the rest of the solution is 1-based.

      iex> window_sum(%{{0,0} => 1, {0,1} => 1, {0,2} => 1, {1,0} => 1, {1,1} => 1, {1,2} => 1, {2,0} => 1, {2,1} => 1, {2,2} => 1}, 1..1, 1..1)
      9
  """
  def window_sum(value_map, x_range, y_range) do
    neighbors = for y <- -1..1, x <- -1..1, do: {x, y}

    for y <- y_range do
      for x <- x_range do
        Enum.reduce(neighbors, 0, fn {dx, dy}, acc -> acc + Map.fetch!(value_map, {x + dx, y + dy}) end)
      end
    end
  end

  @grid_size 300

  @doc """
  Calculate the largest total power.

  ## Approach

  - generate a map with {x,y} => power_level (caution: 1-based)
  - generate a 2-dim list (i,j) from {2,2} up to {299,299}
      - sum {i-1, j-1} + ... + {i+1, j+1}
  - reduce list's first dimension with accumulator {{max_x_index, max_y_index}, max_value} (find max of the all row maxes)
      - reduce list's second dimension (find the max of the row)
  """
  def calculate do
    power_grid(1..@grid_size, 1..@grid_size, 8141)
    # # TODO: |> generate a 2-dim list (i,j) from {2,2} up to {299,299} and sum the entries in
    |> window_sum(2..(@grid_size - 1), 2..(@grid_size - 1))
    |> TwoDimensionMax.two_dimensional_max_with_index
    |> (fn {{x,y}, _} -> {x + 1, y + 1} end).() # we need to correct the coordinates, because we effectively shifted the coordinates by (+1, +1) by giving ranges that started with 2 to window_sum
    |> IO.inspect
  end
end

FuelCell.calculate
|> IO.inspect

# => 235,16