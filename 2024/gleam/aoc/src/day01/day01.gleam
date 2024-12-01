import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

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
  |> string.split("\n")
  |> list.filter(fn(row) { row != "" })
  |> solution_part1()
}

pub fn file_solution_part1() {
  simplifile.read("src/day01/input.txt")
  |> result.lazy_unwrap(fn() { panic })
  |> string.split("\n")
  |> list.filter(fn(row) { row != "" })
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
  |> string.split("\n")
  |> list.filter(fn(row) { row != "" })
  |> solution_part2()
}

pub fn file_solution_part2() {
  simplifile.read("src/day01/input.txt")
  |> result.lazy_unwrap(fn() { panic })
  |> string.split("\n")
  |> list.filter(fn(row) { row != "" })
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

fn parse_lists(rows) {
  rows
  |> list.map(fn(row) {
    let assert [l, r] = string.split(row, "   ")
    #(l |> parse_or_die(), r |> parse_or_die())
  })
  |> list.unzip()
}

fn parse_or_die(val) {
  val |> int.parse() |> result.lazy_unwrap(fn() { panic })
}
