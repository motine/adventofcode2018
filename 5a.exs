defmodule Str do
  def upcase?(s) do
    s == String.upcase(s)
  end

  def downcase?(s) do
    s == String.downcase(s)
  end
end

defmodule Polymer do
  @doc ~S"""
  Tests if unit1 shall react with unit2
  
  ## Examples

      iex> Polymer.reactAll(["a", "b", "B", "A"])
      []
      iex> Polymer.reactAll(["a", "A"])
      []
      iex> Polymer.reactAll(["a", "b", "A", "B"])
      ["a", "b", "A", "B"]
      iex> Polymer.reactAll(["a", "a", "b", "A", "A", "B"])
      ["a", "a", "b", "A", "A", "B"]
      iex> Polymer.react(["A", "b", "B", "a", "c"])
      ["c"]
      iex> Polymer.reactAll(["d", "a", "b", "A", "c", "C", "a", "C", "B", "A", "c", "C", "c", "a", "D", "A"])
      ["d", "a", "b", "C", "B", "A", "c", "a", "D", "A"]
  """
  def reactAll(codepoints) do
    next_reacted = Polymer.react(codepoints)
    if next_reacted != codepoints do
      Polymer.reactAll(next_reacted)
    else
      codepoints
    end
  end

  @doc ~S"""
  Tests if unit1 shall react with unit2
  
  ## Examples

      iex> Polymer.pair?("a", "a")
      false
      iex> Polymer.pair?("a", "B")
      false
      iex> Polymer.pair?("A", "a")
      true
  """
  def pair?(unit1, unit2) do
    String.downcase(unit1) == String.downcase(unit2) &&
      ( (Str.downcase?(unit1) && Str.upcase?(unit2)) ||
        (Str.upcase?(unit1) && Str.downcase?(unit2)) )
  end

  @doc ~S"""
      iex> Polymer.react([])
      []
  """
  def react([]) do
    []
  end

  @doc ~S"""
      iex> Polymer.react(["A"])
      ["A"]
  """
  def react([unit]) do
    [unit]
  end

  @doc ~S"""
      iex> Polymer.react(["A", "a"])
      []
      iex> Polymer.react(["A", "A"])
      ["A", "A"]
  """
  def react([unit1, unit2]) do
    if Polymer.pair?(unit1, unit2) do
      []
    else
      [unit1, unit2]
    end
  end

  @doc ~S"""
      iex> Polymer.react(["A", "a"])
      []
      iex> Polymer.react(["A", "b", "a"])
      ["A", "b", "a"]
      iex> Polymer.react(["A", "b", "B", "a"])
      ["A", "a"]
  """
  def react([unit1, unit2 | tail]) when tail != nil do
    if Polymer.pair?(unit1, unit2) do
      Polymer.react(tail)
    else
      [unit1 | Polymer.react([unit2 | tail])]
    end
  end
end

result = File.read!("5.txt")
  |> String.codepoints()
  |> Polymer.reactAll()

IO.puts(result)
IO.inspect(length(result))

# => 10450
