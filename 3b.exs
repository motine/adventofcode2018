defmodule Claim do
  defstruct [:id, :left, :top, :width, :height]

  def from_string(str) do
    [_ | groups] = Regex.run(~r/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/, str)
    [id, left, top, width, height] = Enum.map(groups, &String.to_integer/1)
    %Claim{id: id, left: left, top: top, width: width, height: height}
  end

  # checks if the given claim overlaps with any of the given claims
  def overlaps?(claim, claims) when is_list(claims) do
    Enum.any?(claims, fn other -> claim != other && Claim.overlaps?(claim, other) end)
  end

  def overlaps?(a, b) do
    a_right = a.left + a.width - 1
    b_right = b.left + b.width - 1
    a_bottom = a.top + a.height - 1
    b_bottom = b.top + b.height - 1
    !((a.left > b_right) || (b.left > a_right) || (a.top > b_bottom) || (b.top > a_bottom))
  end
end

claims = File.read!("3.txt")
  |> String.split("\n")
  |> Enum.map(&Claim.from_string/1)

non_overlapping = Enum.filter(claims, fn claim -> !Claim.overlaps?(claim, claims) end)
IO.inspect(non_overlapping)

# => 919