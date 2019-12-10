defmodule AdventOfCode do
  # converts a string to a map of the form %{ letter => count}
  # example: "abca" yields %{97 => 2, 98 => 1, 99 => 1}
  def letter_frequency(str) do
    str
      |> String.to_charlist
      |> Enum.reduce(%{}, fn (x, acc) ->  Map.put(acc, x, Map.get(acc, x, 0) + 1) end)
  end
end


letter_frequencies = File.read!("2.txt") # read input and split
  |> String.split()
  |> Enum.map(&AdventOfCode.letter_frequency/1) # map the list: create a map: letter -> count

# count items in list: does the line have a double-occurrence (same for triple-occurrences)
doubles = Enum.count(letter_frequencies, fn freqs -> Map.values(freqs) |> Enum.member?(2) end)
triples = Enum.count(letter_frequencies, fn freqs -> Map.values(freqs) |> Enum.member?(3) end)

# multiply & print
IO.inspect(doubles * triples)

# => 7688