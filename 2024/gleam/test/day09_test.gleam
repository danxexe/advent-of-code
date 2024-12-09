import aoc
import day09/day09 as day
import gleeunit/should

pub fn part1_sample_test() {
  "src/day09/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(1928)
}

pub fn part1_input_test() {
  "src/day09/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(6_310_675_819_476)
}
