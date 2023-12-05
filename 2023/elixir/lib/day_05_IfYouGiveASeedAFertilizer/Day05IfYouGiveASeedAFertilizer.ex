defmodule Day05IfYouGiveASeedAFertilizer do

  @sample_data_part_1 """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4
    """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  defmodule Mapping do
    defstruct [source: nil, destination: nil]
  end

  @doc ~S"""
  ## Examples

      iex> Day05IfYouGiveASeedAFertilizer.sample_solution_part1()
      35
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day05IfYouGiveASeedAFertilizer.solution_for_file_part1()
      88151870
  """
  def solution_for_file_part1()

  defp solution_part1(lines) do
    seeds = lines |> Enum.take(1) |> hd() |> parse_int_list()

    {_, maps} = lines
    |> Enum.drop(1)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({nil, []}, &parse_line/2)

    maps = maps
    |> Enum.reverse()
    |> Enum.map(fn {k, v} ->
      {k, v |> Enum.map(&parse_map/1) |> Enum.reverse()}
    end)

    seeds
    |> Enum.map(fn seed -> follow_map(seed, maps) end)
    |> Enum.min()
  end

  defp solution_part2(lines) do
    lines
  end

  defp parse_line(line, {current_key, acc}) do
    if line |> String.contains?(":") do
      [_, key] = Regex.run(~r/^(.*):/, line)
      {key |> String.to_atom, acc}
    else
      current_map = Keyword.get(acc, current_key, [])
      current_map = [line | current_map]
      {current_key, acc |> Keyword.put(current_key, current_map)}
    end
  end

  defp parse_int_list(line) do
    Regex.scan(~r/\d+/, line)
    |> Enum.map(fn [seed] ->
      seed |> Integer.parse() |> elem(0)
    end)
  end

  defp parse_map(line) do
    [destination, source, length] = parse_int_list(line)

    %Mapping{
      source: source..(source + length - 1),
      destination: destination..(destination + length - 1),
    }
  end

  def follow_map(seed, maps) do
    maps
    |> Enum.reduce(seed, fn {_k, maps}, acc ->
      if map = Enum.find(maps, fn mapping -> Enum.member?(mapping.source, acc) end) do
        source = map.source |> Enum.take(1) |> hd()
        dest = map.destination |> Enum.take(1) |> hd()
        acc + (dest - source)
      else
        acc
      end
    end)
  end
end
