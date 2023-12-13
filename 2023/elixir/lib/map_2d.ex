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
