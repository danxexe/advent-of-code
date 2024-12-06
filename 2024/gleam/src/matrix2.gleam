import gary.{type ErlangArray}
import gary/array
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string

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

pub fn reduce(matrix: Matrix2(t), acc: a, callback: fn(a, t) -> a) -> a {
  matrix |> do_reduce(acc, callback, 0, 0)
}

fn do_reduce(
  matrix: Matrix2(t),
  acc: a,
  callback: fn(a, t) -> a,
  x: Int,
  y: Int,
) -> a {
  case x, y {
    _, y if y == matrix.heigth -> acc
    x, _ if x == matrix.width -> do_reduce(matrix, acc, callback, 0, y + 1)
    x, y -> {
      let assert Ok(row) =
        matrix.rows
        |> array.get(y)

      let assert Ok(current) =
        row
        |> array.get(x)

      do_reduce(matrix, callback(acc, current), callback, x + 1, y)
    }
  }
}

pub fn find_first(matrix: Matrix2(t), value: t) {
  matrix |> do_first(value, 0, 0)
}

fn do_first(matrix: Matrix2(t), value: t, x: Int, y: Int) {
  case x, y {
    _, y if y == matrix.heigth -> None
    x, _ if x == matrix.width -> do_first(matrix, value, 0, y + 1)
    x, y -> {
      let assert Ok(row) =
        matrix.rows
        |> array.get(y)

      let assert Ok(current) =
        row
        |> array.get(x)

      case current == value {
        True -> Some(#(x, y))
        False -> do_first(matrix, value, x + 1, y)
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
