import aoc
import gleam/int
import gleam/list
import gleam/string

pub type Report {
  Report(levels: List(Int), is_safe: Bool)
}

pub fn sample_solution_part1() {
  "src/day02/sample.txt"
  |> aoc.file_to_rows()
  |> solution_part1()
}

pub fn input_solution_part1() {
  "src/day02/input.txt"
  |> aoc.file_to_rows()
  |> solution_part1()
}

fn solution_part1(rows: List(String)) {
  rows
  |> list.map(parse_report)
  |> list.filter(fn(report) { report.is_safe })
  |> list.length
}

fn parse_report(row: String) -> Report {
  let levels =
    row
    |> string.split(" ")
    |> list.map(int.parse)
    |> list.map(aoc.or_panic)

  let diffs =
    levels
    |> adjacent_pairs()
    |> list.map(diff)

  let all_increasing = diffs |> list.all(fn(v) { v >= 1 && v <= 3 })
  let all_decreasing = diffs |> list.all(fn(v) { v <= -1 && v >= -3 })

  let is_safe = all_increasing || all_decreasing

  Report(levels:, is_safe:)
}

fn adjacent_pairs(v: List(t)) -> List(#(t, t)) {
  v |> list.zip(list.drop(v, 1))
}

fn diff(pair: #(Int, Int)) -> Int {
  let #(a, b) = pair
  a - b
}
