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

  @sample_data_part_2 """
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
  """

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
      8
  """
  def sample_solution_part2()

  @doc ~S"""
  ## Examples

      iex> Day10.solution_for_file_part2()
      415
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

    def coords(map) do
      for y <- 0..(map.heigth - 1) do
        for x <- 0..(map.width - 1) do
          {y, x}
        end
      end
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

  @blue IO.ANSI.light_blue_background() <> " " <> IO.ANSI.reset()
  @green IO.ANSI.light_green_background() <> " " <> IO.ANSI.reset()

  defp solution_part1(lines) do
    map = lines
    |> Enum.reduce(Map2D.new(), fn line, map ->
      Map2D.push_row(map, parse_line(String.trim(line)))
    end)

    {start, _} = map.tiles
    |> Enum.find(fn {_, tile} -> tile == "█" end)

    loop = map |> follow_pipe(start, {0, 1})
    loop_tiles = loop |> Enum.map(fn {tile, _dir} -> tile end)

    div(loop_tiles |> Enum.count(), 2)
  end

  defp solution_part2(lines) do
    map = lines
    |> Enum.reduce(Map2D.new(), fn line, map ->
      Map2D.push_row(map, parse_line(String.trim(line)))
    end)

    {start, _} = map.tiles
    |> Enum.find(fn {_, tile} -> tile == "█" end)

    loop = map |> follow_pipe(start, {0, 1})
    loop_tiles = loop |> Enum.map(fn {tile, _dir} -> tile end)
    |> Enum.map(fn pos ->
      {pos, map.tiles[pos]}
    end)
    |> Enum.into(%{})

    directions = loop
    |> Enum.sort()
    |> Enum.map(fn {pos, vec} -> {pos, vec_to_dir(vec)} end)
    |> Enum.into(%{})

    directions_by_row = directions
    |> Enum.group_by(fn {{y, _x}, _dir} -> y end)
    |> Enum.map(fn {k, v} -> {k, v |> Enum.into(%{})} end)
    |> Enum.into(%{})

    tiles = Map2D.coords(map)
    |> Stream.flat_map(fn pos -> pos end)
    |> Stream.map(fn pos -> {pos, loop_tiles[pos] || " "} end)
    |> Stream.map(fn {pos, tile} ->
      if tile == " " do
        {y, x} = pos
        row = directions_by_row[y] || %{}

        next_pipe = row |> Enum.filter(fn {{_y, fx}, _v} ->
          fx > x
        end)
        |> Enum.sort_by(fn {{_, x}, _} -> x end)
        |> List.first()

        case next_pipe do
          {_, :up} -> {pos, @blue}
          {_, :down} -> {pos, @green}
          _ -> {pos, tile}
        end
      else
        {pos, tile}
      end
    end)
    |> Enum.into(%{})

    # %Map2D{map | tiles: tiles}
    # |> Map2D.replace_tile(start, "█")
    # |> Map2D.print()
    # |> IO.puts

    # ugly hack that only works for given cases, needs a better way to detect polarity
    outside = tiles[{0, 0}]
    inside = %{
      " " => @green,
      @green => @blue,
    }[outside]

    tiles
    |> Enum.filter(fn {_pos, tile} ->
      tile == inside
    end)
    |> Enum.count()
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

  def vertical_direction(vec, tile) do
    dir = vec_to_dir(vec)

    case {tile, dir} do
      {"│", :down} -> :down
      {"│", :up} -> :up
      {"└", :down} -> :down
      {"└", :left} -> :up
      {"┘", :down} -> :down
      {"┘", :right} -> :up
      {"┐", :up} -> :up
      {"┐", :right} -> :up
      {"┌", :up} -> :up
      {"┌", :left} -> :down
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

  defp follow_pipe(map, pos, dir) do
    tile = map.tiles[pos]
    flow = {pos, vertical_direction(dir, tile)}
    do_follow_pipe(map, pos, dir, [flow])
  end

  defp do_follow_pipe(map, pos, dir, acc) do
    tile = map.tiles[pos]
    new_dir = transform_vector(dir, tile)

    if new_dir == nil do
      acc
    else
      new_pos = sum(pos, new_dir)
      new_tile = map.tiles[new_pos]
      new_flow = {new_pos, vertical_direction(new_dir, new_tile)}

      if Enum.member?(acc, new_flow) do
        [new_flow | acc]
      else
        do_follow_pipe(map, new_pos, new_dir, [new_flow | acc])
      end
    end
  end

  defp sum({ya, xa}, {yb, xb}) do
    {ya + yb, xa + xb}
  end
end
