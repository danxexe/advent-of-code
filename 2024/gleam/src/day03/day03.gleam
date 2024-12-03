import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp

pub type Instruction {
  Do
  Dont
  Mul(Int, Int)
}

pub type State {
  State(enabled: Bool, acc: Int)
}

pub fn solution_part1(rows: List(String)) {
  let assert Ok(pattern) = regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)")

  solution(rows, pattern)
}

pub fn solution_part2(rows: List(String)) {
  let assert Ok(pattern) =
    regexp.from_string("mul\\((\\d{1,3}),(\\d{1,3})\\)|do\\(\\)|don't\\(\\)")

  solution(rows, pattern)
}

pub fn solution(rows: List(String), pattern: regexp.Regexp) {
  let state =
    rows
    |> list.flat_map(parse_row(_, pattern))
    |> list.fold(State(enabled: True, acc: 0), interpret)

  state.acc
}

fn parse_row(row, pattern) {
  regexp.scan(pattern, row) |> list.map(parse_instruction)
}

fn parse_instruction(match: regexp.Match) {
  case match.content {
    "mul" <> _ -> {
      let assert [Some(left), Some(right)] = match.submatches
      let assert Ok(left) = int.parse(left)
      let assert Ok(right) = int.parse(right)

      Mul(left, right)
    }
    "don't" <> _ -> Dont
    "do" <> _ -> Do
    _ -> panic
  }
}

fn interpret(state: State, instruction: Instruction) {
  case state.enabled, instruction {
    True, Mul(l, r) -> State(enabled: True, acc: state.acc + { l * r })
    _, Dont -> State(enabled: False, acc: state.acc)
    _, Do -> State(enabled: True, acc: state.acc)
    _, _ -> state
  }
}
