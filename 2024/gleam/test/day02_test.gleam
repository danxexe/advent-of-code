import aoc
import day02/day02
import gleeunit/should

pub fn day02_part1_sample_test() {
  "src/day02/sample.txt"
  |> aoc.file_to_rows()
  |> day02.solution_part1()
  |> should.equal(2)
}

pub fn day02_part1_input_test() {
  "src/day02/input.txt"
  |> aoc.file_to_rows()
  |> day02.solution_part1()
  |> should.equal(402)
}

pub fn day02_part2_sample_test() {
  "src/day02/sample.txt"
  |> aoc.file_to_rows()
  |> day02.solution_part2()
  |> should.equal(4)
}

pub fn day02_part2_input_test() {
  "src/day02/input.txt"
  |> aoc.file_to_rows()
  |> day02.solution_part2()
  |> should.equal(455)
}
