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

  defmodule Part do
    defstruct [number: nil, row: nil, col: nil, size: nil, valid?: false]
  end

  @doc ~S"""
  ## Examples

      iex> Day03GearRatios.sample_solution_part1()
      4361
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day03GearRatios.solution_for_file_part1()
      538046
  """
  def solution_for_file_part1()

  defp solution_part1(lines) do
    parts = lines
    |> Enum.with_index()
    |> Enum.flat_map(&parse_parts/1)

    map = lines
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.map(&normalize_map_line/1)
    |> Enum.into(%{})

    parts
    |> Enum.map(fn part -> validate_part(part, map) end)
    |> Enum.filter(fn part -> part.valid? end)
    |> Enum.map(fn part -> part.number end)
    |> Enum.sum()
  end

  defp solution_part2(_lines) do
  end

  defp parse_parts({line, row}) do
    parts = Regex.scan(~r/\d+/, line, return: :index)
    |> Enum.map(fn [{col, size}] ->
      number = String.slice(line, col, size) |> Integer.parse() |> elem(0)
      %Part{number: number, row: row, col: col, size: size}
    end)

    parts
  end

  defp normalize_map_line({line, row}) do
    line = line
    |> String.replace(~r/[^.\d]/, "#", global: true)

    {row, line}
  end

  defp validate_part(part, map) do
    left = max(0, part.col - 1)
    right = part.col + part.size

    valid = ""

    valid = valid <> if above = map[part.row - 1] do
      String.slice(above, left..right)
    else
      ""
    end

    valid = valid <> String.slice(map[part.row], left..right)

    valid = valid <> if below = map[part.row + 1] do
      String.slice(below, left..right)
    else
      ""
    end

    %Part{part | valid?: String.contains?(valid, "#")}
  end
end
