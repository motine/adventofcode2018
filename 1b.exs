# ...going with a list for past sums is too slow...
#   def first_number_twice(number_stream, past_sums) do
#     [last_sum | _] = past_sums
#     [current_number] = Enum.take(number_stream, 1)
#     current_sum = last_sum + current_number
#     if Enum.member?(past_sums, current_sum) do
#       current_sum
#     else
#       first_number_twice(Stream.drop(number_stream, 1), [current_sum] ++ past_sums)
#     end
#   end

# ...too slow still...
  # def first_number_twice(number_stream, last_sum, past_sums) do
  #   [current_number] = Enum.take(number_stream, 1)
  #   current_sum = last_sum + current_number
  #   if MapSet.member?(past_sums, current_sum) do
  #     current_sum
  #   else
  #     first_number_twice(Stream.drop(number_stream, 1), current_sum, MapSet.put(past_sums, current_sum))
  #   end
  #   end)

defmodule AdventOfCode do
  # This solution was inspired by another guy's solution
  def first_number_twice(number_stream) do
    Enum.reduce_while(number_stream, {0, MapSet.new([0])}, fn line, {acc, seen} ->
      value = line + acc
      if MapSet.member?(seen, value) do
        {:halt, value}
      else
        {:cont, {value, MapSet.put(seen, value)}}
      end
    end)
  end
end

numbers = File.read!("1.txt")
  |> String.split()
  # improvement: |> Enum.map(&String.to_integer/1)
  |> Enum.map(&Integer.parse/1)
  |> Enum.map(fn {i, ""} -> i end)

result = AdventOfCode.first_number_twice(Stream.cycle(numbers))

IO.puts(result)

# => 549