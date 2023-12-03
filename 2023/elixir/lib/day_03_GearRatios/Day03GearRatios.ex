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

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  defmodule Part do
    defstruct [number: nil, row: nil, col: nil, size: nil, valid?: false]
  end

  defmodule Gear do
    defstruct [row: nil, col: nil, adjacent: nil, parts: [], ratio: nil]
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

  @doc ~S"""
  ## Examples

      iex> Day03GearRatios.sample_solution_part2()
      467835
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day03GearRatios.solution_for_file_part1()
      nil
  """
  def solution_for_file_part2()

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

  defp solution_part2(lines) do
    gears = lines
    |> Enum.with_index()
    |> Enum.flat_map(&parse_gears/1)

    map = lines
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.map(&normalize_map_line/1)
    |> Enum.into(%{})

    parts = lines
    |> Enum.with_index()
    |> Enum.flat_map(&parse_parts/1)
    |> Enum.map(fn part -> validate_part(part, map) end)

    gears
    |> Enum.map(fn gear -> find_adjacent(gear, map) end)
    |> Enum.filter(&with_only_2_adjacent/1)
    |> Enum.map(fn gear -> associate_parts(gear, parts) end)
    |> Enum.map(&compute_ratio/1)
    # |> Enum.map(fn gear -> gear.ratio end)
    # |> Enum.sum()
  end

  defp parse_parts({line, row}) do
    parts = Regex.scan(~r/\d+/, line, return: :index)
    |> Enum.map(fn [{col, size}] ->
      number = String.slice(line, col, size) |> Integer.parse() |> elem(0)
      %Part{number: number, row: row, col: col, size: size}
    end)

    parts
  end

  defp parse_gears({line, row}) do
    gears = Regex.scan(~r/\*/, line, return: :index)
    |> Enum.map(fn [{col, _size}] ->
      %Gear{row: row, col: col}
    end)

    gears
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

  defp find_adjacent(gear, map) do
    left = max(0, gear.col - 1)
    right = gear.col + 1

    adjacent = [
      {gear.row - 1, gear.col, (if above = map[gear.row - 1], do: String.slice(above, left..right))},
      {gear.row, gear.col, String.slice(map[gear.row], left..right)},
      {gear.row + 1, gear.col, (if below = map[gear.row + 1], do: String.slice(below, left..right))},
    ]
    |> Enum.flat_map(&parse_adjacent/1)

    %Gear{gear | adjacent: adjacent}
  end

  defp parse_adjacent({row, gear_col, adjacent}) do
    Regex.scan(~r/\d+/, adjacent, return: :index)
    |> Enum.map(fn [{col, _size}] ->
      {row, gear_col + col - 1}
    end)
  end

  defp with_only_2_adjacent(gear) do
    Enum.count(gear.adjacent) == 2
  end

  defp associate_parts(gear, parts) do
    found = gear.adjacent
    |> Enum.map(fn {row, col} -> find_part_at_position(parts, row, col) end)

    %Gear{gear | parts: found}
  end

  defp find_part_at_position(parts, row, col) do
    parts
    |> Enum.find(fn part ->
      row == part.row && col >= part.col && col <= (part.col + part.size)
    end)
  end

  defp compute_ratio(gear) do
    ratio = gear.parts |> Enum.map(fn part -> part.number end) |> Enum.reduce(fn a, b -> a * b end)
    %Gear{gear | ratio: ratio}
  end
end
