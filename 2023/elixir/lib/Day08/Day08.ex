defmodule Day08 do
  @moduledoc """
  --- Day 8: Haunted Wasteland ---
  """

  @sample_data_part_1 """
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day08.sample_solution_part1()
      2
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day08.solution_for_file_part1()
      nil
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day08.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day08.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()


  defp solution_part1(lines) do
    directions = lines
    |> Enum.take(1) |> hd()
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(&direction/1)

    map = lines
    |> Enum.drop(1)
    |> Enum.map(&parse_map/1)
    |> Enum.into(%{})

    directions
    |> Stream.cycle()
    |> Enum.reduce_while({"AAA", 0}, fn direction, {location, steps} ->
      case {map[location] |> elem(direction), steps} do
        {"ZZZ", steps} -> {:halt, {"ZZZ", steps + 1}}
        {next, steps} -> {:cont, {next, steps + 1}}
      end
    end)
    |> elem(1)
  end

  defp solution_part2(lines) do
    lines
  end

  defp direction(direction) do
    case direction do
      "L" -> 0
      "R" -> 1
    end
  end

  defp parse_map(line) do
    [key, value] = line
    |> String.trim()
    |> String.split(" = ")

    <<_, left::binary-size(3), _, _, right::binary-size(3), _>> = value

    {key, {left, right}}
  end
end
