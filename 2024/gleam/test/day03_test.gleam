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

pub fn day03_part2_sample_test() {
  "src/day03/sample_part2.txt"
  |> aoc.file_to_rows()
  |> day03.solution_part2()
  |> should.equal(48)
}

pub fn day03_part2_input_test() {
  "src/day03/input.txt"
  |> aoc.file_to_rows()
  |> day03.solution_part2()
  |> should.equal(107_862_689)
}
