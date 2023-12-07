defmodule Day02CubeConundrum do

  @sample_data_part_1 """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  defmodule Game do
    defstruct [:id, sets: []]
  end

  defmodule Set do
    defstruct [red: 0, green: 0, blue: 0]
  end

  @doc ~S"""
  ## Examples

      iex> Day02CubeConundrum.sample_solution_part1()
      8
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day02CubeConundrum.solution_for_file_part1()
      2285
  """
  def solution_for_file_part1()

  defp solution_part1(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.map(&max_set/1)
    |> Enum.map(fn {id, set} -> {id, possible?(set)} end)
    |> Enum.filter(fn {_id, possible} -> possible end)
    |> Enum.map(fn {id, _possible} -> id end)
    |> Enum.sum()
  end

  @doc ~S"""
  ## Examples

      iex> Day02CubeConundrum.sample_solution_part2()
      2286
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day02CubeConundrum.solution_for_file_part2()
      77021
  """
  def solution_for_file_part2()

  defp solution_part2(lines) do
    lines
    |> Enum.map(&parse_line/1)
    |> Enum.map(&max_set/1)
    |> Enum.map(fn {_id, set} -> power(set) end)
    |> Enum.sum()
  end

  def parse_line(line) do
    data = Regex.named_captures(~r/^Game\s(?<id>\d+):\s(?<sets>.*)/, line)
    id = data["id"] |> Integer.parse() |> elem(0)
    sets = data
    |> Map.get("sets")
    |> String.split("; ")
    |> Enum.map(&parse_set/1)

    %Game{ id: id, sets: sets }
  end

  defp parse_set(set) do
    bags = set
    |> String.split(", ")
    |> Enum.map(&parse_bag/1)

    %Set{red: bags[:red] || 0, green: bags[:green] || 0, blue: bags[:blue] || 0}
  end

  defp parse_bag(bag) do
    [count, type] = bag |> String.split(" ")
    {String.to_atom(type), Integer.parse(count) |> elem(0)}
  end

  defp max_set(game) do
    max = game.sets
    |> Enum.reduce(%Set{}, fn set, max ->
      %Set{red: max(set.red, max.red), green: max(set.green, max.green), blue: max(set.blue, max.blue)}
    end)

    {game.id, max}
  end

  defp possible?(set) do
    set.red <= 12 && set.green <= 13 && set.blue <= 14
  end

  defp power(set) do
    set.red * set.green * set.blue
  end
end
