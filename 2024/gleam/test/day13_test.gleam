import aoc
import day13/day13 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day13/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(480)
}

pub fn part1_input_test() {
  "src/day13/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(28_887)
}
