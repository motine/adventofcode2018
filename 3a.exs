defmodule Claim do
  defstruct [:id, :left, :top, :width, :height]

  def from_string(str) do
    [_ | groups] = Regex.run(~r/#(\d)+ @ (\d+),(\d+): (\d+)x(\d+)/, str)
    [id, left, top, width, height] = Enum.map(groups, &String.to_integer/1)
    %Claim{id: id, left: left, top: top, width: width, height: height}
  end

  def contains?(claim, x, y) do
    x > claim.left && y > claim.top && x <= claim.left+claim.width && y <= claim.top+claim.height
  end
end

sheet_size = 1000

claims = File.read!("3.txt")
  |> String.split("\n")
  |> Enum.map(&Claim.from_string/1)

# assembles a 1d list by iterating through all coordinates. the values of the list represent the count of Claims that contain the given point
# this is not particularly efficient. we could also Enum.reduce a Range for y. In the fn we would need to Enum.reduce another Range for x.
usage_count_per_coordinate = for x <- 1..sheet_size, y <- 1..sheet_size, do: Enum.count(claims, fn c -> Claim.contains?(c, x, y) end)
coordinates_used_multiple_times = Enum.count(usage_count_per_coordinate, fn count -> count > 1 end)

IO.inspect(coordinates_used_multiple_times)

# => 118840