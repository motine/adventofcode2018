defmodule Str do
  def upcase?(s) do
    s == String.upcase(s)
  end

  def downcase?(s) do
    s == String.downcase(s)
  end
end

defmodule Polymer do
  # see 5a
  def reactAll(codepoints) do
    next_reacted = Polymer.react(codepoints)
    if next_reacted != codepoints do
      Polymer.reactAll(next_reacted)
    else
      codepoints
    end
  end

  # see 5a
  def pair?(unit1, unit2) do
    String.downcase(unit1) == String.downcase(unit2) &&
      ( (Str.downcase?(unit1) && Str.upcase?(unit2)) ||
        (Str.upcase?(unit1) && Str.downcase?(unit2)) )
  end

  # see 5a
  def react([]) do
    []
  end

  # see 5a
  def react([unit]) do
    [unit]
  end

  # see 5a
  def react([unit1, unit2]) do
    if Polymer.pair?(unit1, unit2) do
      []
    else
      [unit1, unit2]
    end
  end

  # see 5a
  def react([unit1, unit2 | tail]) when tail != nil do
    if Polymer.pair?(unit1, unit2) do
      Polymer.react(tail)
    else
      [unit1 | Polymer.react([unit2 | tail])]
    end
  end

  @doc "remove the given unit from the codepoints. unit must be lowercase"
  def remove_type(codepoints, unit) do
    Enum.filter(codepoints, &( String.downcase(&1) != unit))
  end
end

alphabet = ?a..?z
  |> Enum.map(fn i -> <<i :: utf8 >> end)

polymer = File.read!("5.txt")
  |> String.codepoints()

result = Enum.map(alphabet, 
  fn char ->
    Polymer.remove_type(polymer, char)
      |> Polymer.reactAll()
      |> length()
  end)
  |> Enum.min

IO.inspect(result)

# => 4624
