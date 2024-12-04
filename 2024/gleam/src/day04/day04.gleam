import aoc
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string

pub fn solution_part1(rows: List(String)) {
  let split = rows |> list.map(string.split(_, ""))
  let assert Ok(pattern) = regexp.from_string("XMAS")

  let horizontal = split
  let horizontal_reverse = horizontal |> reverse_horizontal()
  let vertical = horizontal |> list.transpose()
  let vertical_reverse = vertical |> reverse_horizontal()

  let diagonal_right = horizontal |> diagonal()
  let diagonal_left = horizontal |> reverse_horizontal() |> diagonal()

  let reverse_diagonal_right = horizontal |> reverse_vertical() |> diagonal()
  let reverse_diagonal_left =
    horizontal |> reverse_vertical() |> reverse_horizontal() |> diagonal()

  let lines =
    list.flatten([
      horizontal,
      horizontal_reverse,
      vertical,
      vertical_reverse,
      diagonal_right,
      diagonal_left,
      reverse_diagonal_right,
      reverse_diagonal_left,
    ])

  lines
  |> list.map(string.join(_, ""))
  |> list.map(count_matches(pattern, _))
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn reverse_horizontal(lines) {
  list.map(lines, list.reverse)
}

fn reverse_vertical(lines) {
  list.reverse(lines)
}

fn diagonal(lines) {
  lines
  |> list.index_map(fn(line, i) {
    let padding = list.repeat(" ", list.length(line) - { i + 1 })
    list.append(padding, line)
  })
  |> list.transpose
}

fn count_matches(pattern, line) {
  regexp.scan(pattern, line)
  |> list.length()
}
