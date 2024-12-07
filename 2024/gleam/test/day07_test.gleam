import aoc
import day07/day07 as day
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

pub fn part1_sample_test() {
  "src/day07/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(3749)
}

pub fn part1_input_test() {
  "src/day07/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(8_401_132_154_762)
}

pub fn part2_sample_test() {
  "src/day07/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(11_387)
}

pub fn part2_input_test_() {
  test_spec.make(fn() {
    "src/day07/input.txt"
    |> aoc.file_to_rows()
    |> day.solution_part2()
    |> should.equal(95_297_119_227_552)
  })
}
