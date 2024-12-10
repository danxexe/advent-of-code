import aoc
import day10/day10 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day10/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(36)
}

pub fn part1_input_test() {
  "src/day10/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(820)
}

pub fn part2_sample_test() {
  "src/day10/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(81)
}

pub fn part2_input_test() {
  "src/day10/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(1786)
}
