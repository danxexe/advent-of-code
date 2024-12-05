import aoc
import day05/day05 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day05/sample.txt"
  |> aoc.file_to_rows_unfiltered()
  |> day.solution_part1()
  |> should.equal(143)
}

pub fn part1_input_test() {
  "src/day05/input.txt"
  |> aoc.file_to_rows_unfiltered()
  |> day.solution_part1()
  |> should.equal(5955)
}
