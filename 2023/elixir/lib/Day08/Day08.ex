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

  @sample_data_part_2 """
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
  """

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
      15989
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day08.sample_solution_part2()
      6
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day08.solution_for_file_part2()
      13830919117339
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
    |> compute_last_location(map, "AAA", fn location, _ -> location == "ZZZ" end)
    |> elem(1)
  end

  defp solution_part2(lines) do
    directions = lines
    |> Enum.take(1) |> hd()
    |> String.trim()
    |> String.codepoints()
    |> Enum.map(&direction/1)

    map = lines
    |> Enum.drop(1)
    |> Enum.map(&parse_map/1)
    |> Enum.into(%{})

    starts = map
    |> Map.keys()
    |> Enum.filter(&starting_location?/1)

    starts
    |> Enum.map(fn location ->
      directions
      |> Stream.cycle()
      |> compute_last_location(map, location, fn location, _ ->
        String.ends_with?(location, "Z")
      end)
      |> elem(1)
    end)
    # Current implementation is terrible
    # |> minimum_common_multiple()
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

  defp starting_location?(location) do
    location |> String.ends_with?("A")
  end

  defp compute_last_location(directions, map, start, is_finish) do
    directions
    |> Enum.reduce_while({start, 0}, fn direction, {location, steps} ->
      next = map[location] |> elem(direction)
      step = steps + 1
      acc = {next, steps + 1}

      if is_finish.(next, step) do
        {:halt, acc}
      else
        {:cont, acc}
      end
    end)
  end

  # defp minimum_common_multiple(values) do
  #   do_minimum_common_multiple(values |> Enum.map(fn v -> {v, v} end))
  # end
  # defp do_minimum_common_multiple(values) do
  #   [{memo, min} | rest] = values |> Enum.sort_by(fn {_k, v} -> v end)

  #   values = [{memo, min + memo} | rest] |> Enum.into(%{})
  #   |> IO.inspect

  #   if all_equal(values |> Map.values) do
  #     values
  #   else
  #     do_minimum_common_multiple(values)
  #   end
  # end

  # defp all_equal([v | values]) do
  #   do_all_equal(values, v) == v
  # end

  # defp do_all_equal([], acc), do: acc
  # defp do_all_equal([v | values], acc) do
  #   if v == acc do
  #     do_all_equal(values, acc)
  #   else
  #     false
  #   end
  # end
end
