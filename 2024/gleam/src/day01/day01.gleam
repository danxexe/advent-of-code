import aoc
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const sample_data_part_1 = "
3   4
4   3
2   5
1   3
3   9
3   3
"

pub fn main() {
  file_solution_part2()
  |> io.debug()
}

pub fn sample_solution_part1() {
  sample_data_part_1
  |> aoc.string_to_rows()
  |> solution_part1()
}

pub fn file_solution_part1() {
  "src/day01/input.txt"
  |> aoc.file_to_rows()
  |> solution_part1()
}

pub fn solution_part1(rows) {
  let rows = rows |> parse_lists()

  let #(left, right) = rows
  let left = left |> list.sort(by: int.compare)
  let right = right |> list.sort(by: int.compare)

  list.zip(left, right)
  |> list.map(fn(pair) {
    let #(l, r) = pair
    int.absolute_value(l - r)
  })
  |> list.fold(from: 0, with: int.add)
}

pub fn sample_solution_part2() {
  sample_data_part_1
  |> aoc.string_to_rows()
  |> solution_part2()
}

pub fn file_solution_part2() {
  "src/day01/input.txt"
  |> aoc.file_to_rows()
  |> solution_part2()
}

pub fn solution_part2(rows) {
  let #(left, right) =
    rows
    |> parse_lists()

  let scores =
    right
    |> list.group(fn(v) { v })
    |> dict.map_values(fn(val, group) { val * list.length(group) })

  let similarity =
    left
    |> list.map(fn(v) { dict.get(scores, v) |> result.unwrap(0) })
    |> list.fold(from: 0, with: int.add)

  similarity
}

fn parse_lists(rows: List(String)) -> #(List(Int), List(Int)) {
  rows
  |> list.map(parse_row)
  |> list.unzip()
}

fn parse_row(row: String) -> #(Int, Int) {
  let assert [l, r] = row |> string.split("   ")
  #(l |> int.parse() |> aoc.or_panic(), r |> int.parse() |> aoc.or_panic())
}
