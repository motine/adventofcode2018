# read input into dependency list (step -> [prestep, prestep, ...])
# function which step is available available?(step, dependencies, [done_step, done_step, ...])
defmodule Dependency do
  @doc "reads the file 7.txt and creates a dependency map from it (e.g. `%{ A: [:X, :Y] }`"
  def read do
    File.read!("7.txt")
      |> String.split("\n")
      |> Enum.reduce(%{}, fn line, acc -> add_dependency(line, acc) end)
  end

  # @doc "parses the given line of the format `Step ? must be finished before step ? can begin.` and adds a dependency to the given dependency map."
  defp add_dependency(line, dependencies) do
    [_ | [prestep_str, step_str]] = Regex.run(~r/Step (.) must be finished before step (.) can begin./, line)
    prestep = String.to_atom(prestep_str)
    step = String.to_atom(step_str)
    Map.update(dependencies, step, [prestep], fn
        value -> value ++ [prestep]
    end)
  end

  @doc "checks if the given step's dependencies are all in done_steps"
  def step_available?(step, dependencies, done_steps) do
    Map.get(dependencies, step, []) # dependencies for this step
      |> Enum.all?(fn dependency -> Enum.member?(done_steps, dependency) end)
  end
  
  @doc "returns all steps that are included in the dependency map (we could have also assumed the whole alphabet)."
  def all_steps(dependencies) do
    Map.keys(dependencies) ++ Enum.flat_map(Map.values(dependencies), &(&1))
      |> Enum.uniq
  end

  @doc "returns a sorted list of all steps that are available after the given steps were done."
  def available_steps(dependencies, done_steps) do
    all_steps(dependencies)
      |> Enum.filter(fn step -> step_available?(step, dependencies, done_steps) end)
      |> Enum.sort
  end

  @doc "returns if all steps were done"
  def done?(all_steps, done_steps) do
    (all_steps -- done_steps) == []
  end

  def instructions do
    dependencies = Dependency.read
    instructions(dependencies, [])
  end

  defp instructions(dependencies, done_steps) do
    if done?(all_steps(dependencies), done_steps) do
      done_steps
    else
      [next_step | _] = available_steps(dependencies, done_steps) -- done_steps
      instructions(dependencies, done_steps ++ [next_step])
    end
  end
end

IO.inspect(Dependency.instructions)


# => CHILFNMORYKGAQXUVBZPSJWDET
