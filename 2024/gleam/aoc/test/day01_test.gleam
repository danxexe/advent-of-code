import day01/day01
import gleeunit/should

pub fn day01_part1_sample_test() {
  day01.sample_solution_part1()
  |> should.equal(11)
}

pub fn day01_part1_file_test() {
  day01.file_solution_part1()
  |> should.equal(2_000_468)
}

pub fn day01_part2_sample_test() {
  day01.sample_solution_part2()
  |> should.equal(31)
}

pub fn day01_part2_file_test() {
  day01.file_solution_part2()
  |> should.equal(18_567_089)
}
