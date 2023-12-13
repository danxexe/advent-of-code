defmodule Day10 do
  @moduledoc """
  --- Day 10: Pipe Maze ---
  """

  @sample_data_part_1 """
  ..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ...
  """

  @sample_data_part_2 @sample_data_part_1

  use Aoc.SolutionUtils

  @doc ~S"""
  ## Examples

      iex> Day10.sample_solution_part1()
      8
  """
  def sample_solution_part1()

  @doc ~S"""
  ## Examples

      iex> Day10.solution_for_file_part1()
      6823
  """
  def solution_for_file_part1()

  @doc ~S"""
  ## Examples

      iex> Day10.sample_solution_part2()
      nil
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day10.solution_for_file_part2()
      nil
  """
  def solution_for_file_part2()

  defmodule Map2D do
    defstruct [width: 0, heigth: 0, tiles: %{}]

    def new do
      %Map2D{}
    end

    def push_row(map, tiles) do
      row = map.heigth

      new_tiles = tiles
      |> Stream.with_index()
      |> Enum.map(fn {tile, col} ->
        {{row, col}, tile}
      end)
      |> Enum.into(%{})
      |> Map.merge(map.tiles)

      %Map2D{map | tiles: new_tiles, width: max(map.width, Enum.count(tiles)), heigth: row + 1}
    end

    def replace_tile(map, pos, tile) do
      %Map2D{map | tiles: map.tiles |> Map.put(pos, tile)}
    end

    def print(map) do
      rows = 0..(map.heigth - 1)
      cols = 0..(map.width - 1)

      rows
      |> Stream.map(fn row ->
        cols
        |> Stream.map(fn col ->
          map.tiles[{row, col}] || " "
        end)
        |> Enum.join("")
      end)
      |> Enum.join("\n")
    end
  end


  defp solution_part1(lines) do
    map = lines
    |> Enum.reduce(Map2D.new(), fn line, map ->
      Map2D.push_row(map, parse_line(String.trim(line)))
    end)

    {start, _} = map.tiles
    |> Enum.find(fn {_, tile} -> tile == "█" end)

    loop_tiles = map |> follow_pipe(start, {0, 1}, [start])

    div(loop_tiles |> Enum.count(), 2)
  end

  defp solution_part2(lines) do
    map = lines
    |> Enum.reduce(Map2D.new(), fn line, map ->
      Map2D.push_row(map, parse_line(String.trim(line)))
    end)

    {start, _} = map.tiles
    |> Enum.find(fn {_, tile} -> tile == "█" end)

    loop_tiles = map |> follow_pipe(start, {0, 1}, [start])
    |> Enum.map(fn pos ->
      {pos, map.tiles[pos]}
    end)
    |> Enum.into(%{})

    %Map2D{map | tiles: loop_tiles}
    |> Map2D.replace_tile(start, "█")
    |> Map2D.print()
    |> IO.puts
  end

  defp parse_line(line) do
    line
    |> String.codepoints()
    |> Enum.map(fn tile ->
      case tile do
        "|" -> "│"
        "-" -> "─"
        "L" -> "└"
        "J" -> "┘"
        "7" -> "┐"
        "F" -> "┌"
        "." -> " "
        "S" -> "█"
        _ -> tile
      end
    end)
  end

  def transform_vector(vec, tile) do
    dir = vec_to_dir(vec)

    case {tile, dir} do
      {"│", :down} -> :down
      {"│", :up} -> :up
      {"─", :right} -> :right
      {"─", :left} -> :left
      {"└", :down} -> :right
      {"└", :left} -> :up
      {"┘", :right} -> :up
      {"┘", :down} -> :left
      {"┐", :right} -> :down
      {"┐", :up} -> :left
      {"┌", :left} -> :down
      {"┌", :up} -> :right
      {"█", dir} -> dir
      _ -> nil
    end
    |> dir_to_vec()
  end

  @dir_to_vec %{
    :down => {1, 0},
    :up => {-1, 0},
    :right => {0, 1},
    :left => {0, -1},
  }

  @vec_to_dir @dir_to_vec
  |> Enum.map(fn {a, b} -> {b, a} end)
  |> Enum.into(%{})

  def dir_to_vec(dir) do
    @dir_to_vec[dir]
  end

  def vec_to_dir(vec) do
    @vec_to_dir[vec]
  end

  defp follow_pipe(map, pos, dir, acc) do
    tile = map.tiles[pos]
    new_dir = transform_vector(dir, tile)

    if new_dir == nil do
      [nil | acc]
    else
      new_pos = sum(pos, new_dir)

      if Enum.member?(acc, new_pos) do
        [new_pos | acc]
      else
        follow_pipe(map, new_pos, new_dir, [new_pos | acc])
      end
    end
  end

  defp sum({ya, xa}, {yb, xb}) do
    {ya + yb, xa + xb}
  end
end
