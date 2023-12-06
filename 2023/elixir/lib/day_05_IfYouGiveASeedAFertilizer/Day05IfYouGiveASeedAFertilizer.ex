defmodule D05 do
  require IEx

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

  defmodule Layer do
    defstruct [:name, :mappings]
  end

  defmodule Mapping do
    defstruct [:source, :shift]
  end

  defmodule MappingTransform do
    defstruct [:range, :mapping, :intersection, :shifted, :difference, :mapped]
  end

  defmodule LayerTransform do
    defstruct [:name, :mappings, :normalized, :next]
  end

  @doc ~S"""
  ## Examples

      iex> D05.sample_solution_part1()
      35
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> D05.solution_for_file_part1()
      88151870
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> D05.sample_solution_part2()
      46
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> D05.solution_for_file_part2()
      2008785
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

  def solution_part2(lines) do
    seeds = lines |> Enum.take(1) |> hd() |> parse_int_list()
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, size] -> (start..start+size-1) end)

    {_, maps} = lines
    |> Enum.drop(1)
    |> Enum.map(&String.trim/1)
    |> Enum.reduce({nil, []}, &parse_line/2)

    layers = maps
    |> Enum.reverse()
    |> Enum.map(fn {k, v} ->
      %Layer{
        name: k |> to_string(),
        mappings: v |> Enum.map(&parse_map/1) |> Enum.sort_by(fn mapping -> mapping.source.first end),
      }
    end)

    last_transform = layers
    |> Enum.reduce(seeds, fn layer, acc ->
      ranges = case acc do
        %LayerTransform{normalized: normalized} -> normalized
        ranges -> ranges
      end

      normalized = map_next_range(layer.mappings, ranges, [])
      %LayerTransform{name: layer.name, normalized: normalized}
    end)

    last_transform.normalized
    |> Enum.map(fn range -> range |> Enum.min end)
    |> Enum.min
  end

  defp map_next_range(_mappings, [], acc), do: acc
  defp map_next_range(mappings, [range | rest], acc) do
    found = mappings
    |> Enum.find(fn mapping -> !Range.disjoint?(range, mapping.source) end)

    case found do
      nil -> map_next_range(mappings, rest, [range | acc])
      mapping -> case apply_mapping(mapping, range) do
        %MappingTransform{shifted: shifted, difference: []} ->
          map_next_range(mappings, rest, shifted ++ acc)
        %MappingTransform{shifted: shifted, difference: difference} ->
          map_next_range(mappings, difference ++ rest, shifted ++ acc)
      end
    end
  end

  defp apply_mapping(mapping, range) do
    intersection = RangeOperation.intersection(range, mapping.source)
    difference = RangeOperation.difference(range, mapping.source)
    shifted = intersection |> Enum.map(fn range -> Range.shift(range, mapping.shift) end)

    mapped = (shifted ++ difference)

    %MappingTransform{
      range: range,
      mapping: mapping,
      intersection: intersection,
      shifted: shifted,
      difference: difference,
      mapped: mapped,
    }
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
    %Mapping{source: source..(source + length - 1), shift: destination - source}
  end

  def follow_map(seed, maps) do
    maps
    |> Enum.reduce(seed, fn maps, acc ->
      if map = Enum.find(maps, fn mapping -> Enum.member?(mapping.source, acc) end) do
        acc + map.shift
      else
        acc
      end
    end)
  end
end
