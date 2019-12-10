# this solution is heavily based on 4a
#
# Approach:
#   read file
#   do lexicographic sort
#   parse lines into %Sleep{id: , start_min: , end_min: }
#     group %Sleep list by id %Map{ id: [%Sleep, %Sleep, ...], ...}
defmodule Sleep do
  defstruct [:id, :start_min, :end_min]

  @doc "returns a list of %Sleep by parsing the given file"
  def parse_file(filename) do
    lines = File.read!(filename)
      |> String.split("\n")
      |> Enum.sort(&(&1 <= &2))
    parse_lines(lines)
  end
  
  @doc "see 4a"
  def duration(sleep) do
    sleep.end_min - sleep.start_min
  end

  @doc "see 4a"
  def asleep?(sleep, min) do
    min >= sleep.start_min && min < sleep.end_min
  end

  # see 4a
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

defmodule SleepHour do
  defstruct minutes: List.duplicate(0, 60)


  @doc ~S"""
  Adds 1 to each minute the guard was asleep during given sleep.

  ## Examples

      iex> SleepHour.apply(%SleepHour{}, %Sleep{id: 1, start_min: 10, end_min: 20})
      %SleepHour{ minutes: [0,0,0,0,0,0,0,0,0,0, 1,1,1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0] }
  """
  def apply(sleep_hour, sleep) do
    minutes = sleep_hour.minutes
      |> Enum.with_index
      |> Enum.map(fn {count, min} -> if Sleep.asleep?(sleep, min), do: count + 1, else: count end)
    %SleepHour{ minutes: minutes }
  end

  @doc ~S"""
  Applies (see above) the given sleeps to a fresh %SleepHour{}

  ## Examples

      iex> SleepHour.from_sleeps([%Sleep{id: 1, start_min: 10, end_min: 20}, %Sleep{id: 1, start_min: 15, end_min: 30}])
      %SleepHour{ minutes: [0,0,0,0,0,0,0,0,0,0, 1,1,1,1,1,2,2,2,2,2, 1,1,1,1,1,1,1,1,1,1, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0] }
  """
  def from_sleeps(sleeps) when is_list(sleeps) do
    Enum.reduce(sleeps, %SleepHour{},
      fn sleep, acc ->
        SleepHour.apply(acc, sleep)
      end
    )
  end

  @doc ~S"""
  Returns the {count, minute} of the sleepiest minute in the given %SleepHour
  
  ## Examples

      iex> SleepHour.sleepiest_minute(%SleepHour{ minutes: [0,0,0,0,0,0,0,0,0,5, 1,0,0,0,0,2,2,2,2,2, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0] })
      {5, 9}
  """
  def sleepiest_minute(sleep_hour) do
    sleep_hour.minutes
      |> Enum.with_index
      |> Enum.max_by(fn {count, _min} -> count end)
  end

  # def test do
  #   SleepHour.sleepiest_minute(%SleepHour{ minutes: [0,0,0,0,0,0,0,0,0,5, 1,0,0,0,0,2,2,2,2,2, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0] })
  # end
end


sleeps = Sleep.parse_file("4.txt")

{id, {count, min}} = sleeps
  |> Enum.group_by(&(&1.id)) # sleeps_by_id: group sleeps by id (e.g. %{ 3137: [%Sleep, %Sleep, ...], ...}
  |> Map.new(fn {id, sleeps}-> {id, SleepHour.from_sleeps(sleeps)} end) # sleep_hours_by_id
  |> Enum.to_list
  |> Enum.map(fn {id, sleep_hour} -> {id, SleepHour.sleepiest_minute(sleep_hour)} end)
  |> Enum.max_by(fn {_id, {count, _min}} -> count end)

IO.inspect("The guard #{id} slept #{count} times at minute #{min}.")
IO.inspect("Result #{id * min}.")

# => 53024
