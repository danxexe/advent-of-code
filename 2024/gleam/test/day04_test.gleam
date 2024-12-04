import aoc
import day04/day04
import gleeunit/should

pub fn day04_part1_sample_test() {
  "src/day04/sample.txt"
  |> aoc.file_to_rows()
  |> day04.solution_part1()
  |> should.equal(18)
}

pub fn day04_part1_input_test() {
  "src/day04/input.txt"
  |> aoc.file_to_rows()
  |> day04.solution_part1()
  |> should.equal(2434)
}
