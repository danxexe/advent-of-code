defmodule Day03GearRatios do

  @sample_data_part_1 """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

  @sample_data_part_2 nil

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day03GearRatios.sample_solution_part1()
      4361
  """
  def sample_solution_part1()

  defp solution_part1(lines) do
    lines
    |> Enum.map(&String.codepoints/1)
    |> Enum.to_list()
  end

  defp solution_part2(_lines) do
  end
end
