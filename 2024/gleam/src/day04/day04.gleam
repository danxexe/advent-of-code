import aoc
import gleam/int
import gleam/list
import gleam/regexp
import gleam/string
import gleam/yielder

pub fn solution_part1(rows: List(String)) {
  let split = rows |> to_grid()
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

fn to_grid(rows) {
  rows |> list.map(string.split(_, ""))
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

const xmas_pattern = "
M.S
.A.
M.S
"

pub fn solution_part2(rows: List(String)) {
  let patterns =
    xmas_pattern
    |> pattern_rotations()
    |> yielder.take(4)
    |> yielder.to_list

  rows
  |> to_grid()
  |> grid_slices(3, 3)
  |> yielder.filter(fn(grid) {
    patterns
    |> list.map(grid_matches(grid, _))
    |> list.fold(False, fn(a, b) { a || b })
  })
  |> yielder.length()
}

fn pattern_rotations(pattern) -> yielder.Yielder(List(regexp.Regexp)) {
  let pattern =
    pattern
    |> string.trim()
    |> string.split("\n")
    |> list.map(string.split(_, ""))

  yielder.iterate(pattern, rotate)
  |> yielder.map(fn(grid) {
    grid
    |> list.map(string.join(_, ""))
    |> list.map(fn(row) { regexp.from_string(row) |> aoc.or_panic() })
  })
}

fn rotate(grid) {
  grid
  |> list.transpose()
  |> reverse_horizontal()
}

fn grid_slices(grid, w, h) {
  let assert Ok(head) = list.first(grid)
  let range_w = yielder.range(0, list.length(head) - w)
  let range_h = yielder.range(0, list.length(grid) - h)

  yielder.map(range_w, fn(x) {
    yielder.map(range_h, fn(y) {
      grid
      |> list.drop(y)
      |> list.take(h)
      |> list.map(fn(row) {
        row
        |> list.drop(x)
        |> list.take(w)
      })
    })
  })
  |> yielder.flatten
}

fn grid_matches(grid: List(List(String)), patterns) {
  list.map2(grid, patterns, fn(row, pattern) {
    let row = row |> string.join("")
    regexp.check(pattern, row)
  })
  |> list.fold(True, fn(a, b) { a && b })
}
