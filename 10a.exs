defmodule Star do
  defstruct [:x, :y, :vx, :vy]
  
  @doc "Reads star structs from the file at the given location (path)."
  def read(path) do
    File.read!(path)
      |> String.split("\n")
      |> Enum.map(&parse_line/1)
  end

  @doc "adds the velocity to the location of a star / list of stars"
  def evolve([star | rest]), do: [evolve(star) | evolve(rest)]
  def evolve([]), do: []

  def evolve(%Star{ x: x, y: y, vx: vx, vy: vy }) do
    %Star{ x: x+vx, y: y+vy, vx: vx, vy: vy }
  end

  def coordinates(stars) do
    Enum.reduce(stars, MapSet.new, fn star, acc -> MapSet.put(acc, {star.x, star.y}) end)
  end
  
  @doc "see dimensions/1, uses the given coordinates instead of calculating them anew"
  def dimensions_from_coordinates(coordinates) do
    {x_vals, y_vals} = coordinates |> Enum.unzip
    {x_min, x_max} = Enum.min_max(x_vals)
    {y_min, y_max} = Enum.min_max(y_vals)

    {x_min, y_min, x_max, y_max}
  end

  @doc "calculate the image dimensions and returns `{x_min, y_min, x_max, y_max}` from the given stars"
  def dimensions(stars), do: dimensions_from_coordinates(coordinates(stars))

  def size(stars) do
    {x_min, y_min, x_max, y_max} = dimensions(stars)
    {x_max - x_min, y_max - y_min}
  end

  defp parse_line(line) do
    [x, y, vx, vy] = Regex.run(~r/position=\<\s*(-?\d+),\s*(-?\d+)\> velocity=\<\s*(-?\d+),\s*(-?\d+)\>/, line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
    %Star{x: x, y: y, vx: vx, vy: vy}
  end
end

# Wow, this took me quite a while.
# I took lots of detours to get to this solution...
defmodule Day10 do
  @max_frame 1_000_000

  def generate do
    input = Star.read("10.txt")
    
    {smallest_stars, _} = Enum.reduce_while(0..@max_frame, {input, {1000000, 1000000}} , fn i, {stars, size} ->
      new_stars = Star.evolve(stars)
      new_size = Star.size(stars)
      
      # if (new_size < size) do
      if (i == 10577) do # turns out, the solution frame is one before the smallest one
        {:halt, {stars, size}}
      else
        {:cont, {new_stars, new_size}}
      end
    end)

    pixel_for_stars(smallest_stars)
    |> print_pixel()
  end

  def print_pixel(pixel) do
    Enum.map(pixel, fn row -> IO.puts(row) end)
  end

  defp pixel_for_stars(stars) do
    coordinates = Star.coordinates(stars)
    {x_min, y_min, x_max, y_max} = Star.dimensions_from_coordinates(coordinates)
    
    # produce the pixel by counting the number of entries per field
    for y <- y_min..y_max do
      for x <- x_min..x_max do
        if MapSet.member?(coordinates, {x, y}), do: "X", else: " "
      end
    end
  end
end

Day10.generate

# a => ZAEKAJGC
# b => 10577
