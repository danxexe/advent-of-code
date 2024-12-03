import aoc
import day03/day03
import gleeunit/should

pub fn day03_part1_sample_test() {
  "src/day03/sample.txt"
  |> aoc.file_to_rows()
  |> day03.solution_part1()
  |> should.equal(161)
}

pub fn day03_part1_input_test() {
  "src/day03/input.txt"
  |> aoc.file_to_rows()
  |> day03.solution_part1()
  |> should.equal(184_122_457)
}
