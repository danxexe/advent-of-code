import aoc
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}

pub type Report {
  Report(levels: List(Int), is_safe: Bool)
}

pub fn solution_part1(rows: List(String)) -> Int {
  rows
  |> list.map(parse_report)
  |> list.filter(fn(report) { report.is_safe })
  |> list.length
}

pub fn solution_part2(rows: List(String)) {
  let reports =
    rows
    |> list.map(parse_report)

  reports
  |> list.map(with_single_level_removed)
  |> list.map(fn(variations) {
    variations |> yielder.find(fn(report) { report.is_safe })
  })
  |> list.filter(result.is_ok(_))
  |> list.length()
}

fn parse_report(row: String) -> Report {
  let levels =
    row
    |> string.split(" ")
    |> list.map(int.parse)
    |> list.map(aoc.or_panic)

  Report(levels:, is_safe: is_safe(levels))
}

fn is_safe(levels: List(Int)) -> Bool {
  let diffs =
    levels
    |> adjacent_pairs()
    |> list.map(diff)

  let all_increasing = diffs |> list.all(fn(v) { v >= 1 && v <= 3 })
  let all_decreasing = diffs |> list.all(fn(v) { v <= -1 && v >= -3 })

  all_increasing || all_decreasing
}

fn adjacent_pairs(v: List(t)) -> List(#(t, t)) {
  v |> list.zip(list.drop(v, 1))
}

fn diff(pair: #(Int, Int)) -> Int {
  let #(a, b) = pair
  a - b
}

fn with_single_level_removed(report: Report) -> Yielder(Report) {
  let levels_with_index =
    report.levels
    |> yielder.from_list()
    |> yielder.index()

  levels_with_index
  |> yielder.transform(0, fn(i, _) {
    let levels =
      levels_with_index
      |> yielder.filter(fn(pair) { i != pair.1 })
      |> yielder.map(fn(pair) { pair.0 })
      |> yielder.to_list()

    yielder.Next(Report(levels:, is_safe: is_safe(levels)), i + 1)
  })
  |> yielder.prepend(report)
}
