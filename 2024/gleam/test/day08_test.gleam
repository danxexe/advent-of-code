import aoc
import day08/day08 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day08/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(14)
}

pub fn part1_input_test() {
  "src/day08/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(320)
}

pub fn part2_sample_test() {
  "src/day08/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(34)
}

pub fn part2_input_test() {
  "src/day08/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(1157)
}
