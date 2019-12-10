defmodule AdventOfCode do
  def differs_by_one?(a, b) do
    difference_count = Enum.zip(a, b)
      |> Enum.count(fn {a_char, b_char} -> a_char != b_char end)
    difference_count == 1
  end

  def has_corresponding?(ids, id) do
    Enum.any?(ids,
      fn other_id -> AdventOfCode.differs_by_one?(id, other_id) end)
  end
end

ids = File.read!("2.txt") # read input, split and convert to chars
  |> String.split()
  |> Enum.map(&String.to_charlist/1)

# generate list: keep item if it has a corresponding item which differs by one.
ids_with_corresponding = ids
  |> Enum.reduce([], 
    fn (id, acc) ->
      if AdventOfCode.has_corresponding?(ids, id) do
        [id] ++ acc
      else
        acc
      end
    end)

IO.inspect(ids_with_corresponding)

# occurrence 1: lsrivmotzbdxpkxnaqmuwcychj
# occurrence 2: lsrivmotzbdxpkxnaqmuwcgchj

# => lsrivmotzbdxpkxnaqmuwcchj