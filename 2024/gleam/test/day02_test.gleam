import day02/day02
import gleeunit/should

pub fn day02_part1_sample_test() {
  day02.sample_solution_part1()
  |> should.equal(2)
}

pub fn day02_part1_input_test() {
  day02.input_solution_part1()
  |> should.equal(402)
}
