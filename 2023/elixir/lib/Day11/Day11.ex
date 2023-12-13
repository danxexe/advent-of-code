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
      nil
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day11.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day11.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()


  defp solution_part1(lines) do
    map = lines
    |> expand_universe()
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
    lines
    |> expand_universe()
  end

  defp duplicate_empty_line(line) do
    if String.contains?(line, "#") do
      [line]
    else
      [line, line]
    end
  end

  defp flip(lines) do
    lines
    |> Stream.map(fn line -> String.codepoints(line) end)
    |> Stream.zip()
    |> Stream.map(fn codepoints -> codepoints |> Tuple.to_list() |> Enum.join("") end)
  end

  defp expand_universe(lines) do
    lines
    |> Stream.map(&String.trim/1)
    |> Stream.flat_map(&duplicate_empty_line/1)
    |> flip()
    |> Stream.flat_map(&duplicate_empty_line/1)
    |> flip()
  end

  defp step_distance([a, b]) do
    {ay, ax} = a
    {by, bx} = b

    abs(ay - by) + abs(ax - bx)
  end
end
