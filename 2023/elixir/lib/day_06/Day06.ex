defmodule Day06 do
  @moduledoc """
  --- Day 6: Wait For It ---
  """

  @sample_data_part_1 """
  Time:      7  15   30
  Distance:  9  40  200
  """
  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day06.sample_solution_part1()
      288
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day06.solution_for_file_part1()
      nil
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day06.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day06.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()

  defmodule Race do
    defstruct [:time, :distance, :options]
  end


  defp solution_part1(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.zip
    |> Enum.map(&parse_race/1)
    |> Enum.map(&compute_options/1)
    |> Enum.reduce(1, fn race, acc -> race.options * acc end)
  end

  defp solution_part2(_lines) do
  end

  defp parse_line(line) do
    Regex.scan(~r/\d+/, line)
    |> Enum.map(fn [n] -> Integer.parse(n) |> elem(0) end)
  end

  defp parse_race({time, distance}) do
    %Race{time: time, distance: distance}
  end

  defp compute_options(race) do
    options = (1..race.time-1)
    |> Stream.map(fn holding ->
      racing = race.time - holding
      {holding, racing, holding * racing}
    end)
    |> Stream.filter(fn {_, _, distance} -> distance > race.distance end)
    |> Enum.count()

    %Race{race | options: options}
  end
end
