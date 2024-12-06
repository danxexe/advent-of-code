import aoc
import day06/day06 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day06/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(41)
}

pub fn part1_input_test() {
  "src/day06/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(5551)
}
