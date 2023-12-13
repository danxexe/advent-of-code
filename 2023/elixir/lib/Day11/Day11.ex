defmodule Day11 do
  @moduledoc """
  --- Day 11: Cosmic Expansion ---
  """

  @sample_data_part_1 """
  ...#......
  .......#..
  #.........
  ..........
  ......#...
  .#........
  .........#
  ..........
  .......#..
  #...#.....
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day11.sample_solution_part1()
      374
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day11.solution_for_file_part1()
      10313550
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day11.sample_solution_part2()
      82000210
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day11.solution_for_file_part2()
      611998089572
  """
  def solution_for_file_part2()


  defp solution_part1(lines) do
    map = lines
    |> expand_universe(2)
    |> Enum.reduce(Map2D.new, fn line, map ->
      map |> Map2D.push_row(line |> String.codepoints)
    end)

    tiles = map.tiles
    |> Stream.filter(fn {_pos, tile} -> tile == "#" end)
    |> Enum.map(fn {pos, _} -> pos end)

    tiles
    |> EnumEx.combinations(2)
    |> Enum.map(&step_distance/1)
    |> Enum.sum()
  end

  defp solution_part2(lines) do
    map = lines
    |> Stream.map(&String.trim/1)
    |> Enum.reduce(Map2D.new, fn line, map ->
      map |> Map2D.push_row(line |> String.codepoints)
    end)

    galaxies = map.tiles
    |> Stream.filter(fn {_pos, tile} -> tile == "#" end)
    |> Enum.map(fn {pos, _} -> pos end)

    galaxies
    |> expand_universe_v2(map, 1000000)
    |> EnumEx.combinations(2)
    |> Enum.map(&step_distance/1)
    |> Enum.sum()
  end

  defp duplicate_empty_line(line, times) do
    if String.contains?(line, "#") do
      [line]
    else
      (1..times)
      |> Stream.map(fn _ -> line end)
    end
  end

  defp flip(lines) do
    lines
    |> Stream.map(fn line -> String.codepoints(line) end)
    |> Stream.zip()
    |> Stream.map(fn codepoints -> codepoints |> Tuple.to_list() |> Enum.join("") end)
  end

  defp expand_universe(lines, times) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(fn line -> duplicate_empty_line(line, times) end)
    |> flip()
    |> Stream.flat_map(fn line -> duplicate_empty_line(line, times) end)
    |> flip()
  end

  defp expand_universe_v2(galaxies, map, times) do
    rows = galaxies
    |> Enum.map(fn {row, _} -> row end)
    |> Enum.uniq()

    empty_rows = Enum.to_list(0..map.heigth - 1) -- rows

    cols = galaxies
    |> Enum.map(fn {_, col} -> col end)
    |> Enum.uniq()

    empty_cols = Enum.to_list(0..map.width - 1) -- cols

    galaxies
    |> Enum.map(fn {row, col} ->
      grow_row = empty_rows |> Enum.filter(fn r -> row > r end) |> Enum.count()
      grow_row = (grow_row * times) - grow_row

      grow_col = empty_cols |> Enum.filter(fn c -> col > c end) |> Enum.count()
      grow_col = (grow_col * times) - grow_col

      {row + grow_row, col + grow_col}
    end)
  end

  defp step_distance([a, b]) do
    {ay, ax} = a
    {by, bx} = b

    abs(ay - by) + abs(ax - bx)
  end
end
