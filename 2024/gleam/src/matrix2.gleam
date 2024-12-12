import gary.{type ErlangArray}
import gary/array
import gleam/dynamic
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import vec2.{type Vec2}

pub type Matrix2(t) {
  Matrix2(
    rows: ErlangArray(ErlangArray(t)),
    width: Int,
    heigth: Int,
    default: t,
  )
}

pub fn from_list(rows: List(List(t)), default: t) -> Matrix2(t) {
  let assert Ok(head) = rows |> list.first()
  let width = head |> list.length()
  let heigth = rows |> list.length()

  Matrix2(
    rows: rows
      |> list.map(fn(row) {
        row
        |> array.from_list(default)
      })
      |> array.from_list(array.from_list([], default)),
    width: width,
    heigth: heigth,
    default:,
  )
}

pub fn inspect(matrix: Matrix2(_)) -> String {
  matrix.rows
  |> array.sparse_map(fn(_, row) {
    row
    |> array.sparse_map(fn(_, val) {
      let val = val |> dynamic.from()

      case val |> dynamic.classify() {
        "String" -> val |> dynamic.string() |> result.unwrap("")
        "Int" -> val |> dynamic.int() |> result.unwrap(0) |> int.to_string()
        val -> val |> string.inspect()
      }
    })
    |> array.to_list
    |> string.join("")
  })
  |> array.to_list()
  |> string.join("\n")
}

pub fn debug(matrix: Matrix2(t)) -> Matrix2(t) {
  matrix
  |> inspect()
  |> io.println_error()

  matrix
}

pub fn fold(
  matrix: Matrix2(t),
  acc: a,
  callback: fn(a, t, #(Int, Int)) -> a,
) -> a {
  matrix |> do_fold(acc, callback, 0, 0)
}

fn do_fold(
  matrix: Matrix2(t),
  acc: a,
  callback: fn(a, t, #(Int, Int)) -> a,
  x: Int,
  y: Int,
) -> a {
  case x, y {
    _, y if y == matrix.heigth -> acc
    x, _ if x == matrix.width -> do_fold(matrix, acc, callback, 0, y + 1)
    x, y -> {
      let assert Ok(row) =
        matrix.rows
        |> array.get(y)

      let assert Ok(current) =
        row
        |> array.get(x)

      do_fold(matrix, callback(acc, current, #(x, y)), callback, x + 1, y)
    }
  }
}

pub fn filter_index(
  matrix: Matrix2(t),
  callback: fn(t) -> Bool,
) -> List(#(Int, Int)) {
  matrix
  |> fold([], fn(acc, val, pos) {
    case callback(val) {
      True -> [pos, ..acc]
      False -> acc
    }
  })
  |> list.reverse()
}

pub fn find_first(matrix: Matrix2(t), value: t) {
  matrix |> do_first(fn(v) { value == v }, 0, 0)
}

pub fn find_first_with(
  matrix: Matrix2(t),
  callback: fn(t) -> Bool,
) -> option.Option(#(Int, Int)) {
  matrix |> do_first(callback, 0, 0)
}

fn do_first(matrix: Matrix2(t), callback: fn(t) -> Bool, x: Int, y: Int) {
  case x, y {
    _, y if y == matrix.heigth -> None
    x, _ if x == matrix.width -> do_first(matrix, callback, 0, y + 1)
    x, y -> {
      let assert Ok(row) =
        matrix.rows
        |> array.get(y)

      let assert Ok(current) =
        row
        |> array.get(x)

      case callback(current) {
        True -> Some(#(x, y))
        False -> do_first(matrix, callback, x + 1, y)
      }
    }
  }
}

pub fn get(matrix: Matrix2(t), pos: #(Int, Int)) -> t {
  case matrix.rows |> array.get(pos.1) {
    Ok(row) -> {
      case row |> array.get(pos.0) {
        Ok(val) -> val
        _ -> matrix.default
      }
    }
    _ -> matrix.default
  }
}

pub fn getv(matrix: Matrix2(t), pos: Vec2) -> t {
  get(matrix, #(pos.x, pos.y))
}

pub fn set(matrix: Matrix2(t), pos: #(Int, Int), val: t) -> Matrix2(t) {
  let assert Ok(row) =
    matrix.rows
    |> array.get(pos.1)

  let assert Ok(new_row) =
    row
    |> array.set(pos.0, val)

  let assert Ok(new_rows) = matrix.rows |> array.set(pos.1, new_row)

  Matrix2(..matrix, rows: new_rows)
}

pub fn setv(matrix: Matrix2(t), pos: Vec2, value: t) -> Matrix2(t) {
  let row = matrix.rows |> array.get(pos.y)

  case row {
    Ok(row) -> {
      let new_row = row |> array.set(pos.x, value)
      case new_row {
        Ok(new_row) -> {
          let assert Ok(new_rows) = matrix.rows |> array.set(pos.y, new_row)
          Matrix2(..matrix, rows: new_rows)
        }
        Error(_) -> matrix
      }
    }
    Error(_) -> matrix
  }
}

pub fn deletev(matrix: Matrix2(t), pos: Vec2) -> Matrix2(t) {
  let row = matrix.rows |> array.get(pos.y)

  case row {
    Ok(row) -> {
      let new_row = row |> array.drop(pos.x)
      case new_row {
        Ok(new_row) -> {
          let assert Ok(new_rows) = matrix.rows |> array.set(pos.y, new_row)
          Matrix2(..matrix, rows: new_rows)
        }
        Error(_) -> matrix
      }
    }
    Error(_) -> matrix
  }
}

pub fn is_in_bounds(matrix: Matrix2(_), pos: Vec2) -> Bool {
  pos.x >= 0 && pos.y >= 1 && pos.x < matrix.width && pos.y < matrix.heigth
}

pub fn sparse_map(matrix2: Matrix2(t), callback: fn(t) -> t) -> Matrix2(t) {
  let rows =
    matrix2.rows
    |> array.sparse_map(fn(_, row) {
      row |> array.sparse_map(fn(_, v) { callback(v) })
    })

  Matrix2(..matrix2, rows:)
}
