defmodule Day05IfYouGiveASeedAFertilizer do

  @sample_data_part_1 """
    seeds: 3394639029

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
    defstruct [source: nil, diff: nil]
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

  @doc ~S"""
  ## Examples

      iex> Day05IfYouGiveASeedAFertilizer.sample_solution_part2()
      46
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day05IfYouGiveASeedAFertilizer.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()

  defp solution_part1(lines) do
    seeds = lines |> Enum.take(1) |> hd() |> parse_int_list()

    {_, maps} = lines
    |> Enum.drop(1)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({nil, []}, &parse_line/2)

    maps = maps
    |> Enum.reverse()
    |> Enum.map(fn {_k, v} ->
      v |> Enum.map(&parse_map/1) |> Enum.reverse()
    end)

    seeds
    |> Enum.map(fn seed -> follow_map(seed, maps) end)
    |> Enum.min()
  end

  @doc ~S"""
  Terrbile attempt at "backtracking" the solution with unrolled loops.
  Apply mappings in reverse only for the smallest humidity-to-location range,
  Then brute-force for the seed ranges found.

  The current answer, 194991402, still takes a long time to compute
  and is wrong anyway. Committing this for future :facepalm: purposes.

  The actual optimized solution should be something like:
  - For each layer (including seeds)
    - Merge ranges if !Range.disjoint?(a, b): min(a.first, b.first)..max(a.last, b.last)
    - For each range
      - Reduce source mappings of next layer, spliting into {before, join, after}
      - Map new ranges to destination
  """
  defp solution_part2(lines) do
    DateTime.utc_now() |> IO.inspect
    seeds = lines |> Enum.take(1) |> hd() |> parse_int_list()
    |> Stream.chunk_every(2)
    |> Stream.map(fn [start, len] ->
      start..(start + len - 1)
    end)

    {_, maps} = lines
    |> Stream.drop(1)
    |> Stream.map(&String.trim/1)
    |> Enum.reduce({nil, []}, &parse_line/2)

    maps = maps
    |> Enum.reverse()
    |> Enum.map(fn {_k, v} ->
      v |> Enum.map(&parse_map/1) |> Enum.reverse()
    end)

    indexes = []

    # humidity-to-location
    layer = maps
    |> Enum.at(6)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      {range.first + diff, range}
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {{first, range}, i} -> first end)

    {{_min, range}, i} = sorted |> hd()
    indexes = [[i] | indexes]

    # 2984989380..3009100645
    range

    # temperature-to-humidity
    layer = maps
    |> Enum.at(5)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.filter(fn {r, _i} -> r.first <= range.first && r.last >= range.last end)

    {range, i} = sorted |> hd()
    indexes = [[i] | indexes]

    # 2631474761..3690130271
    range

    # light-to-temperature
    layer = maps
    |> Enum.at(4)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {r, _i} -> Range.disjoint?(r, range) end)

    ranges = sorted
    |> Enum.map(fn {range, _i} -> range end)
    indexes = [sorted |> Enum.map(fn {_,i} -> i end) | indexes]

    # water-to-light
    layer = maps
    |> Enum.at(3)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {a, _i} ->
      ranges |> Enum.reduce(fn b, acc ->
        acc && Range.disjoint?(a, b)
      end)
    end)

    ranges = sorted
    |> Enum.map(fn {range, _i} -> range end)
    indexes = [sorted |> Enum.map(fn {_,i} -> i end) | indexes]

    # fertilizer-to-water
    layer = maps
    |> Enum.at(2)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {a, _i} ->
      ranges |> Enum.reduce(fn b, acc ->
        acc && Range.disjoint?(a, b)
      end)
    end)

    ranges = sorted
    |> Enum.map(fn {range, _i} -> range end)
    indexes = [sorted |> Enum.map(fn {_,i} -> i end) | indexes]

    # soil-to-fertilizer
    layer = maps
    |> Enum.at(1)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {a, _i} ->
      ranges |> Enum.reduce(fn b, acc ->
        acc && Range.disjoint?(a, b)
      end)
    end)

    ranges = sorted
    |> Enum.map(fn {range, _i} -> range end)
    indexes = [sorted |> Enum.map(fn {_,i} -> i end) | indexes]

    # seed-to-soil
    layer = maps
    |> Enum.at(0)

    sorted = layer
    |> Enum.map(fn {range, diff} ->
      (range.first + diff)..(range.last + diff)
    end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {a, _i} ->
      ranges |> Enum.reduce(fn b, acc ->
        acc && Range.disjoint?(a, b)
      end)
    end)

    ranges = sorted
    |> Enum.map(fn {range, _i} -> range end)
    indexes = [sorted |> Enum.map(fn {_,i} -> i end) | indexes]

    # seeds
    sorted = seeds
    |> Enum.with_index()
    |> Enum.sort_by(fn {range, i} -> range.first end)
    |> Enum.reject(fn {a, _i} ->
      ranges |> Enum.reduce(fn b, acc ->
        acc && Range.disjoint?(a, b)
      end)
    end)
    |> Enum.map(fn {range, _i} -> range end)

    filtered_maps = Enum.zip(maps, indexes)
    |> Enum.map(fn {layer, filter} ->
      layer
      |> Enum.with_index()
      |> Enum.filter(fn {_map, i} -> Enum.member?(filter, i) end)
    end)

    [3394639029..3454329438, 3492562455..3785530503, 3890048781..4223500385]
    |> Stream.flat_map(fn seed -> seed end)
    |> Stream.map(fn seed ->
      if rem(seed, 100000) == 0, do: IO.puts(seed)
      follow_map(seed, maps)
    end)
    |> Enum.min()
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
    {source..(source + length - 1), destination - source}
  end

  def follow_map(seed, maps) do
    maps
    |> Enum.reduce(seed, fn maps, acc ->
      if map = Enum.find(maps, fn {source, _} -> Enum.member?(source, acc) end) do
        {_, diff} = map
        acc + diff
      else
        acc
      end
    end)
  end
end
