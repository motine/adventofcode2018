total = File.read!("1.txt")
  |> String.split()
  |> Enum.map(&Integer.parse/1)
  |> Enum.map(fn {i, ""} -> i end)
  |> Enum.sum

IO.puts(total)

# => 508