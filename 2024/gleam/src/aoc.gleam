import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn string_to_rows(input: String) -> List(String) {
  input
  |> string.split("\n")
  |> list.filter(fn(row) { row != "" })
}

pub fn file_to_rows(filename: String) -> List(String) {
  filename
  |> file_to_rows_unfiltered()
  |> list.filter(fn(row) { row != "" })
}

pub fn file_to_rows_unfiltered(filename: String) -> List(String) {
  filename
  |> simplifile.read()
  |> result.lazy_unwrap(fn() { panic })
  |> string.split("\n")
}

pub fn or_panic(result: Result(t, _)) -> t {
  result |> result.lazy_unwrap(fn() { panic })
}

pub fn to_int_or_panic(input: String) -> Int {
  input
  |> int.parse()
  |> or_panic()
}
