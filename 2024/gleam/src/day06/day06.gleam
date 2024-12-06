import gleam/list
import gleam/option.{Some}
import gleam/string
import gleam/yielder
import matrix2.{type Matrix2}

type Map {
  Map(position: #(Int, Int), grid: Matrix2(String), in_bounds: Bool)
}

pub fn solution_part1(rows: List(String)) {
  let grid =
    rows
    |> list.map(string.split(_, ""))
    |> matrix2.from_list(" ")

  let assert Some(position) =
    grid
    |> matrix2.find_first("^")

  let assert Ok(last_map) =
    Map(grid:, position:, in_bounds: True)
    |> yielder.iterate(fn(map) {
      map
      |> walk()
    })
    |> yielder.find(fn(map) { !map.in_bounds })

  last_map.grid
  |> matrix2.reduce(0, fn(acc, char) {
    case char == "X" {
      True -> acc + 1
      False -> acc
    }
  })
}

fn walk(map: Map) -> Map {
  let char =
    map.grid
    |> matrix2.get(map.position)

  case char {
    "^" -> map |> move_up()
    ">" -> map |> move_right()
    "v" -> map |> move_down()
    "<" -> map |> move_left()
    _ -> map
  }
}

fn move_up(map: Map) -> Map {
  let new_position = #(map.position.0, map.position.1 - 1)
  let #(new, old, new_position) = case map.grid |> matrix2.get(new_position) {
    "#" -> #("#", ">", map.position)
    _ -> #("^", "X", new_position)
  }

  map |> update_map(new_position, old, new)
}

fn move_right(map: Map) -> Map {
  let new_position = #(map.position.0 + 1, map.position.1)
  let #(new, old, new_position) = case map.grid |> matrix2.get(new_position) {
    "#" -> #("#", "v", map.position)
    _ -> #(">", "X", new_position)
  }

  map |> update_map(new_position, old, new)
}

fn move_down(map: Map) -> Map {
  let new_position = #(map.position.0, map.position.1 + 1)
  let #(new, old, new_position) = case map.grid |> matrix2.get(new_position) {
    "#" -> #("#", "<", map.position)
    _ -> #("v", "X", new_position)
  }

  map |> update_map(new_position, old, new)
}

fn move_left(map: Map) -> Map {
  let new_position = #(map.position.0 - 1, map.position.1)
  let #(new, old, new_position) = case map.grid |> matrix2.get(new_position) {
    "#" -> #("#", "^", map.position)
    _ -> #("<", "X", new_position)
  }

  map |> update_map(new_position, old, new)
}

fn update_map(map: Map, new_position, old_char, new_char) -> Map {
  let in_bounds = is_in_bounds(new_position, #(map.grid.width, map.grid.heigth))
  let grid = case in_bounds {
    True -> {
      map.grid
      |> matrix2.set(new_position, new_char)
      |> matrix2.set(map.position, old_char)
    }
    False -> {
      map.grid
      |> matrix2.set(map.position, "X")
    }
  }

  Map(position: new_position, grid: grid, in_bounds:)
}

fn is_in_bounds(pos: #(Int, Int), bounds: #(Int, Int)) -> Bool {
  pos.0 >= 0 && pos.1 >= 1 && pos.0 < bounds.0 && pos.1 < bounds.1
}
