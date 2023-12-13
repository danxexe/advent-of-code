defmodule EnumEx do
  def combinations(_, 0), do: [[]]
  def combinations([], _), do: []
  def combinations([h|t], m) do
      (for l <- combinations(t, m-1), do: [h|l]) ++ combinations(t, m)
  end
end
