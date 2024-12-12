import aoc
import day12/day12 as day
import gleeunit/should

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
// pub fn part2_input_test_() {
//   test_spec.make(fn() {
//     "src/day11/input.txt"
//     |> aoc.file_to_rows()
//     |> day.solution_part2()
//     |> should.equal(224_577_979_481_346)
//   })
// }
