import aoc
import day11/day11 as day
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

pub fn part1_sample_test() {
  "src/day11/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(55_312)
}

pub fn part1_input_test() {
  "src/day11/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(189_547)
}

pub fn part2_input_test_() {
  test_spec.make(fn() {
    "src/day11/input.txt"
    |> aoc.file_to_rows()
    |> day.solution_part2()
    |> should.equal(224_577_979_481_346)
  })
}
