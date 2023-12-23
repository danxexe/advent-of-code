defmodule Day12 do
  @moduledoc """
  --- Day 0: Sample ---
  """

  @sample_data_part_1 """
  ???.### 1,1,3
  .??..??...?##. 1,1,3
  ?#?#?#?#?#?#?#? 1,3,1,6
  ????.#...#... 4,1,1
  ????.######..#####. 1,6,5
  ?###???????? 3,2,1
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day12.sample_solution_part1()
      21
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day12.solution_for_file_part1()
      nil
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day12.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day12.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()

  defmodule Row do
    defstruct [:raw, :ranges, :arrangements]

    def inspect(row) do
      arrangements = row.arrangements
      |> Enum.map(fn ranges -> inspect_ranges(row.raw, ranges) end)
      |> Enum.join("\n")

      "---" <> "\n" <>
      row.raw <> "\n" <>
      arrangements
    end

    defp inspect_ranges(raw, ranges) do
      placeholder = String.duplicate(" ", String.length(raw))
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {k,v} -> {v,k} end)
      |> Enum.into(%{})

      ranges
      |> Stream.flat_map(fn v -> v end)
      |> Enum.reduce(placeholder, fn i, acc ->
        acc |> Map.put(i, "#")
      end)
      |> Enum.sort_by(fn {k,_} -> k end)
      |> Enum.map(fn {_,v} -> v end)
      |> Enum.join()
    end
  end


  defp solution_part1(lines) do
    rows = lines
    |> Stream.map(&parse_row/1)
    |> Stream.map(&fit_left/1)
    |> Stream.map(&shift_right/1)

    rows_reverse = rows
    |> Enum.map(fn row ->
      %Row{row | ranges: row.ranges |> Enum.reverse()}
    end)
    |> Stream.map(&fit_left/1)
    |> Stream.map(&shift_right/1)
    |> Enum.map(fn row ->
      %Row{row | ranges: row.ranges |> Enum.reverse()}
    end)

    # rows
    # |> Stream.map(&Row.inspect/1)
    # |> Enum.each(&IO.puts/1)

    rows_reverse
    |> Stream.map(&Row.inspect/1)
    |> Enum.each(&IO.puts/1)
  end

  defp solution_part2(lines) do
    lines
  end

  defp parse_row(line) do
    [raw, lengths] = line |> String.trim() |> String.split(" ")
    ranges = lengths |> String.split(",") |> Enum.map(&String.to_integer/1) |> to_ranges()

    %Row{
      raw: raw,
      ranges: ranges,
    }
  end

  def to_ranges(lengths) do
    do_to_ranges(lengths, 0, []) |> Enum.reverse()
  end
  defp do_to_ranges(_lengths = [], _pos, ranges), do: ranges
  defp do_to_ranges([len | rest] = _lengths, pos, ranges) do
    range = pos..(pos + len - 1)
    pos = range.last + 2

    do_to_ranges(rest, pos, [range | ranges])
  end

  def fit_left(row) do
    ranges = do_fit_left(row.raw, row.ranges, []) |> Enum.reverse()
    %Row{row | ranges: ranges}
  end
  defp do_fit_left(_str, _ranges = [], fitted), do: fitted
  defp do_fit_left(str, [range | rest], fitted) do
    fit = String.slice(str, range)
    gap = String.slice(str, range.last + 1, 1)
    if String.contains?(fit, ".") || gap == "#" do
      do_fit_left(str, [range | rest] |> Enum.map(fn r -> Range.shift(r, 1) end), fitted)
    else
      do_fit_left(str, rest, [range | fitted])
    end
  end

  def shift_right(row) do
    {_ranges, arrangements} = do_shift_right(row.raw, row.ranges |> Enum.reverse(), {[], []})
    %Row{row | arrangements: [row.ranges | Enum.reverse(arrangements)]}
  end
  defp do_shift_right(_str, _ranges = [], {shifted, arrangements}), do: {shifted, arrangements}
  defp do_shift_right(str, [range | rest], {shifted, arrangements}) do
    shift = range |> Range.shift(1)
    slice = String.slice(str, shift)

    shifted_ranges = ranges = [shift | rest] ++ shifted
    if match_groups?(str, ) do
      # {str, _} = String.split_at(str, range.first - 1)
      do_shift_right(str, rest, {[range | shifted], arrangements})
    else
      ranges = [shift | rest] ++ shifted
      do_shift_right(str, [shift | rest], {shifted, [ranges | arrangements]})
    end
  end

  def match_groups?(str, expected_groups) do
    groups = str |> String.split(~r/\.+/) |> Enum.reject(fn g -> g == "" end)
    |> Enum.map(&String.length/1)

    groups == expected_groups
  end
end
