import aoc
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/regexp

pub fn solution_part1(rows: List(String)) {
  let assert Ok(pattern) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")
  rows
  |> list.flat_map(parse_row(_, pattern))
  |> list.reduce(int.add)
  |> aoc.or_panic()
}

fn parse_row(row, pattern) {
  regexp.scan(pattern, row) |> list.map(parse_match)
}

fn parse_match(match: regexp.Match) {
  let assert [left, right] = match.submatches
  let left = left |> parse_int()
  let right = right |> parse_int()

  left * right
}

fn parse_int(val: Option(String)) -> Int {
  val |> option.lazy_unwrap(fn() { panic }) |> int.parse() |> aoc.or_panic()
}
