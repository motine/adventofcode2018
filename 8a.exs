defmodule LicenseNode do
  defstruct children: [], metadata: []

  # returns a tuple with the parsed Node and the data that was not processed
  # returns the data that was not processed yet
  def parse([0, metadata_count | data]) do
    { %LicenseNode{ children: [], metadata: Enum.take(data, metadata_count) }, Enum.drop(data, metadata_count) }
  end

  def parse([child_count, metadata_count | data]) do
    { children, data_after_children } = Enum.map_reduce(1..child_count, data, fn _i, acc ->
      parse(acc)
    end)
    metadata = Enum.take(data_after_children, metadata_count)
    { %LicenseNode{ children: children, metadata: metadata }, Enum.drop(data_after_children, metadata_count) }
  end

  def deep_sum(%LicenseNode{children: children, metadata: metadata}) do
    children_sums = Enum.map(children, &deep_sum/1)
    Enum.sum(children_sums) + Enum.sum(metadata)
  end
end

{ root_node, [] } = File.read!("8.txt")
  |> String.split()
  |> Enum.map(&String.to_integer/1)
  |> LicenseNode.parse

IO.inspect(LicenseNode.deep_sum(root_node))

# => 43996