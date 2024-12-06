import aoc
import day06/day06 as day
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

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

// pub fn part2_sample_test() {
//   "src/day06/sample.txt"
//   |> aoc.file_to_rows()
//   |> day.solution_part2()
//   |> should.equal(6)
// }

pub fn part2_input_test_() {
  test_spec.make(fn() {
    "src/day06/input.txt"
    |> aoc.file_to_rows()
    |> day.solution_part2()
    // |> should.equal(41)
  })
}
