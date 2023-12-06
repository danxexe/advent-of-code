defmodule RangeOperation do

  @doc ~S"""
  ## Examples

      iex> RangeOperation.intersection(0..1, 2..3)
      []

      iex> RangeOperation.intersection(0..3, 2..4)
      [2..3]

      iex> RangeOperation.intersection(2..4, 0..3)
      [2..3]

      iex> RangeOperation.intersection(0..3, 0..3)
      [0..3]
  """
  def intersection(a, b) do
    if Range.disjoint?(a, b) do
      []
    else
      [max(a.first, b.first)..min(a.last, b.last)//a.step]
    end
  end

  @doc ~S"""
  ## Examples

      # disjoint
      iex> RangeOperation.difference(0..1, 2..3)
      [0..1]

      # in the middle
      iex> RangeOperation.difference(0..5, 2..4)
      [0..1, 5..5]

      # to the left
      iex> RangeOperation.difference(0..6, 2..6)
      [0..1]

      # to the right
      iex> RangeOperation.difference(0..6, 0..4)
      [5..6]
  """
  def difference(a, b) do
    if Range.disjoint?(a, b) do
      [a]
    else
      [intersection] = intersection(a, b)
      [a.first..intersection.first-1//a.step, intersection.last+1..a.last//a.step]
      |> Enum.reject(fn range -> Range.size(range) == 0 end)
    end
  end

  @doc ~S"""
  ## Examples

      iex> RangeOperation.union(0..1, 2..3)
      [0..3]

      iex> RangeOperation.union(0..1, 3..4)
      [0..1, 3..4]

      iex> RangeOperation.union(3..4, 0..1)
      [3..4, 0..1]

      iex> RangeOperation.union(0..4, 3..5)
      [0..5]
  """
  def union(a, b) do
    if !Range.disjoint?(a, b) || consecutive?(a, b) do
      [min(a.first, b.first)..max(a.last, b.last)//a.step]
    else
      [a, b]
    end
  end

  def consecutive?(a, b) do
    Range.disjoint?(a, b) && (a.last + 1 == b.first || b.last + 1 == a.first)
  end
end
