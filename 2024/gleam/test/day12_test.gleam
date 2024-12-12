import aoc
import day12/day12 as day
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

pub fn part1_sample_test() {
  "src/day12/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(1930)
}

pub fn part1_input_test() {
  "src/day12/input.txt"
  |> aoc.file_to_rows()
  |> day.solution_part1()
  |> should.equal(1_533_644)
}

pub fn part2_sample_test() {
  "src/day12/sample.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(1206)
}

pub fn part2_sample2_test() {
  "src/day12/sample2.txt"
  |> aoc.file_to_rows()
  |> day.solution_part2()
  |> should.equal(368)
}

pub fn part2_input_test_() {
  test_spec.make(fn() {
    "src/day12/input.txt"
    |> aoc.file_to_rows()
    |> day.solution_part2()
    |> should.equal(936_718)
  })
}
