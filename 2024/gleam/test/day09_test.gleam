import aoc
import day09/day09 as day
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

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

pub fn part2_sample_test() {
  "src/day09/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(2858)
}

pub fn part2_input_test_() {
  test_spec.make(fn() {
    "src/day09/input.txt"
    |> aoc.file_to_rows()
    |> day.solution_part2()
    |> should.equal(6_335_972_980_679)
  })
}
