# Approach:
#   read file
#   do lexicographic sort
#   parse lines into %Sleep{id: , start_min: , end_min: }
#     group %Sleep list by id %Map{ id: [%Sleep, %Sleep, ...], ...}
#     reduce list of %Sleep into %Map{ id: duration, ... }
#     chosen guard: pick the id with the maximum duration
#   generate a list with 60 items/minutes
#     for each %Sleep of this guard:
#     add 1 to each item/minutes the guard was asleep
#     chosen minute: find the maximum index in this list

defmodule Sleep do
  defstruct [:id, :start_min, :end_min]

  # returns a list of %Sleep by parsing the given file
  def parse_file(filename) do
    lines = File.read!(filename)
      |> String.split("\n")
      |> Enum.sort(&(&1 <= &2))
    parse_lines(lines)
  end
 
  @doc ~S"""
  Get the duration
      iex> Sleep.duration(%Sleep{id: 1, start_min: 1, end_min: 5})
      4
  """
  def duration(sleep) do
    sleep.end_min - sleep.start_min
  end

  @doc ~S"""
  Test if the guard was asleep at the given minute
      iex> Sleep.asleep?(%Sleep{id: 1, start_min: 1, end_min: 5}, 0)
      false
      iex> Sleep.asleep?(%Sleep{id: 1, start_min: 1, end_min: 5}, 1)
      true
      iex> Sleep.asleep?(%Sleep{id: 1, start_min: 1, end_min: 5}, 3)
      true
      iex> Sleep.asleep?(%Sleep{id: 1, start_min: 1, end_min: 5}, 5)
      false
      iex> Sleep.asleep?(%Sleep{id: 1, start_min: 1, end_min: 5}, 10)
      false
      4
  """
  def asleep?(sleep, min) do
    min >= sleep.start_min && min < sleep.end_min
  end

  defp parse_lines(lines) do
    Enum.reduce(
      lines,
      %{last_id: -1, last_start_min: -1, sleeps: []}, 
      fn line, acc -> 
        case Regex.run(~r/\[\d{4}-\d{2}-\d{2} \d{2}:(\d{2})\] (\w+) #?(\d+)?/, line) do
          [_, min, "falls"] -> %{ acc | last_start_min: String.to_integer(min) } # remember last start minute
          [_, min, "wakes"] -> %{ acc | sleeps: [ %Sleep{id: acc.last_id, start_min: acc.last_start_min, end_min: String.to_integer(min)} | acc.sleeps] } # add entry to sleeps
          [_, _, "Guard", id] -> %{ acc | last_id: String.to_integer(id) } # remember last id
        end
      end).sleeps
  end

end

sleeps = Sleep.parse_file("4.txt")

{sleepiest_id, sleepiest_duration} = sleeps
  |> Enum.group_by(&(&1.id), &Sleep.duration/1) # sleep_durations_by_id: results in a map id: [duration, ...] (e.g. %{ 3137: [177, 333, 555], ...}
  |> Map.new(fn {id, durations}-> {id, Enum.sum(durations)} end) # sleep_sum_by_id: sum up the duration list into one value
  |> Enum.to_list
  |> Enum.max_by(fn {_, duration} -> duration end)

IO.inspect("Sleepiest guard #{sleepiest_id} slept #{sleepiest_duration} minutes.")

sleeps_of_sleepiest_guard = Enum.filter(sleeps, &(&1.id == sleepiest_id))
minutes = for min <- 0..59, do: {min, Enum.count(sleeps_of_sleepiest_guard, fn sleep -> Sleep.asleep?(sleep, min) end)}
{sleepiest_minute, sleeps_for_minute} = Enum.max_by(minutes, fn {_, sleeps_for_minute} -> sleeps_for_minute end)

IO.inspect("Sleepiest guard slept #{sleeps_for_minute} times on minute #{sleepiest_minute}.")

IO.inspect("The result is #{sleepiest_id * sleepiest_minute}")

# => 21083
