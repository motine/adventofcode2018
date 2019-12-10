# Approach:
# find the max dimensions of the grid
#   we can safely eliminate outside coordinates, because the area of a location there must be infinite
# go through all possible (x,y) using the max dimensions to generate a map which maps coordinate index to area:
#   which coordinate does the current (x,y) belong to?
#   generate a list: add 1 to the current location's area
# generate the same map again, just with slightly bigger dimensions
# keep only the items that have the same area in the first and second map (because we consider growing ones to be infinite ones)
# get the maximum

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

  @doc ~S"""
  Returns the index of which location is the closest in the given list.
  Returns nil if it is a tie (same distance).

  ## Examples

  Example grid for tests (upper case letters are the actual points, numbered alphabetically A=0,B=1,...):
  
  ```
  aaaaa.cccc
  aAaaa.cccc
  aaaddecccc
  aadddeccCc
  ..dDdeeccc
  bb.deEeecc
  bBb.eeee..
  bbb.eeefff
  bbb.eeffff
  bbb.ffffFf
  ```

      iex> Coordinate.closest_index(%Coordinate{x: 0, y: 0}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      0
      iex> Coordinate.closest_index(%Coordinate{x: 1, y: 1}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      0
      iex> Coordinate.closest_index(%Coordinate{x: 4, y: 3}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      3
      iex> Coordinate.closest_index(%Coordinate{x: 5, y: 0}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      nil
      iex> Coordinate.closest_index(%Coordinate{x: 1, y: 4}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      nil
      iex> Coordinate.closest_index(%Coordinate{x: 7, y: 1}, [%Coordinate{x: 1, y: 1}, %Coordinate{x: 1, y: 6}, %Coordinate{x: 8, y: 3}, %Coordinate{x: 3, y: 4}, %Coordinate{x: 5, y: 5}, %Coordinate{x: 8, y: 9}])
      2
  """
  def closest_index(coordinate, locations) do
    {result_index, _result_distance} = locations
      |> Enum.with_index()
      |> Enum.reduce({nil, 1000}, fn {cur_location, cur_index}, {min_index, min_distance} ->
          cur_distance = Coordinate.distance(cur_location, coordinate)
          cond do
            cur_distance < min_distance -> { cur_index, cur_distance }
            cur_distance == min_distance -> { nil, cur_distance }
            cur_distance > min_distance -> { min_index, min_distance }
          end
        end)
    result_index
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

  # maps index to area.
  # the indexes belong to the items of the given locations
  # and the area is determined by going through all coordinates within [(left_top.x, left_top.y) to (right_bottom.x, right_bottom.y)].
  def area_map(left_top, right_bottom, locations) do
    Coordinate.all_in(left_top, right_bottom) # generate a list of all coordinates within the max dimensions
      |> Enum.reduce(%{}, fn coordinate, area_map -> # we build an area map which maps the index of a coordinate to the number of times it was closest (which is the same as the area) 
          closest_index = Coordinate.closest_index(coordinate, locations)
          {_, newmap} = Map.get_and_update(area_map, closest_index, fn old_val -> {old_val, (old_val || 0) + 1} end)
          newmap
        end)
  end

  def main do
    locations = File.read!("6.txt")
      |> String.split("\n")
      |> Enum.map(fn line -> [x, y] = String.split(line, ", "); %Coordinate{x: String.to_integer(x), y: String.to_integer(y)} end)

    max_dimensions = Coordinate.max_coordinate(locations)
    # we generate the map for the max dimensions
    # then we generate the map for slightly bigger dimensions
    # if the area grow from the first to the second map, we can assume that these coordinates are infinite
    map1 = Coordinate.area_map(%Coordinate{x: 0, y: 0}, max_dimensions, locations)
    map2 = Coordinate.area_map(%Coordinate{x: -50, y: -50}, %Coordinate{x: max_dimensions.x+50, y: max_dimensions.y+50}, locations)
    Map.merge(map1, map2, fn _k, area1, area2 -> if area1 == area2 do area1 else false end end)
      |> Enum.filter(fn {_k, area} -> area end)
      |> Enum.max_by(fn {_index, area} -> area end)
  end
end

IO.inspect(Coordinate.main)

# => 3890
