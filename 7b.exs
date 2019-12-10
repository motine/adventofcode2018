# create a function which evolves one second.
# params:
# - passed_seconds: increments by one each call
# - worker_list: list of a) how many each worker still has to work on his task, b) which task he is working on; decrement 1 second each call, if 0 then add the step to the done list
# - done_steps: set of symbols representing the steps
#
# logic:
# 1. reduce the seconds and add to the done steps
# 2. start workers for each task that is now possible (if workers are available)

defmodule Worker do
  defstruct [:current_step, :remaining_seconds]

  # evolves the worker by 1 second.
  # returns the [evolved_worker, nil] if the worker is still busy with doing something.
  # returns the [evolved_worker, step] if he just finished it.
  #
  # ## Examples
  #     iex> Worker.tick(%Worker{current_step: :X, remaining_seconds: 3})
  #     {%Worker{current_step: :X, remaining_seconds: 2}, nil}
  #     
  #     iex> Worker.tick(%Worker{current_step: :X, remaining_seconds: 2})
  #     {%Worker{current_step: :X, remaining_seconds: 1}, nil}
  #     
  #     iex> Worker.tick(%Worker{current_step: :X, remaining_seconds: 1})
  #     {%Worker{current_step: nil, remaining_seconds: nil}, :X}
  #     
  #     iex> Worker.tick(%Worker{current_step: nil, remaining_seconds: 0})
  #     {%Worker{current_step: nil, remaining_seconds: nil}, nil}
  def tick(%Worker{current_step: nil, remaining_seconds: _}) do
    {%Worker{}, nil}
  end

  def tick(%Worker{current_step: step, remaining_seconds: 1}) do
    {%Worker{}, step}
  end

  def tick(%Worker{current_step: step, remaining_seconds: secs}) do
    {%Worker{current_step: step, remaining_seconds: secs - 1}, nil}
  end

  def start_step(step) do
    %Worker{ current_step: step, remaining_seconds: Worker.step_duration(step) }
  end

  def free?(%Worker{ current_step: nil }), do: true
  def free?(_), do: false

  # returns the duration of a step (:A=1, :B=2, ...)
  #
  # ## Examples
  #     iex> Worker.step_duration(:A)
  #     61
  #     iex> Worker.step_duration(:Z)
  #     86
  def step_duration(step, offset \\ 60) do
    [char] = Atom.to_charlist(step)
    offset + char - 64
  end

  def steps_working_on(worker_list) do
    steps = Enum.map(worker_list, fn
      %Worker{current_step: nil, remaining_seconds: nil} -> nil
      %Worker{current_step: step} -> step
    end)
    Enum.filter(steps, &(&1)) # filter out nil
  end
end

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

  # returns a new worker_list with as many steps started as possible (if any)
  def employ_free_workers(worker_list, steps_to_start) do
    Enum.reduce(steps_to_start, worker_list, fn step, list ->
        free_worker_index = Enum.find_index(list, &(Worker.free?(&1)))
        if free_worker_index do
          List.replace_at(list, free_worker_index, Worker.start_step(step))
        else
          list
        end
      end)
  end

  def tick do
    dependencies = Dependency.read
    worker_list = for _ <- 1..5, do: %Worker{}
    tick(0, worker_list, [], dependencies)
  end

  # Evolves the given parameter by 1 second:
  #
  # - passed_seconds: increments by 1 each call
  # - worker_list: list of a) how many each worker still has to work on his task, b) which task he is working on; decrement 1 second each call, if 0 then add the step to the done list
  # - done_steps: set of symbols representing the steps
  def tick(passed_seconds, worker_list, done_steps, dependencies) do
    if done?(all_steps(dependencies), done_steps) do
      passed_seconds
    else
      # assign available steps to available workers
      steps_to_start = (Dependency.available_steps(dependencies, done_steps) -- Worker.steps_working_on(worker_list)) -- done_steps
      worker_list = employ_free_workers(worker_list, steps_to_start)
      # evolve each worker in the worker list by 1 second
      {worker_list, finished_steps} = Enum.map(worker_list, &Worker.tick/1) # each tick returns: { worker_list, step_finished }
        |> Enum.unzip
      # and add finished workers' steps to done_steps (without nil values)
      done_steps = done_steps ++ Enum.filter(finished_steps, &(&1))
      # recurse
      tick(passed_seconds + 1, worker_list, done_steps, dependencies)
    end
  end
end

IO.inspect(Dependency.tick())

# => 891
