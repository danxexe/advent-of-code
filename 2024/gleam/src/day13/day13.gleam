import aoc
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/yielder.{type Yielder}
import vec2.{type Vec2}

type Button {
  Button(inc: Vec2, cost: Int)
}

type Machine {
  Machine(a: Button, b: Button, prize: Vec2)
}

type Input {
  Input(a_presses: Int, b_presses: Int, position: Vec2, cost: Int)
}

pub fn solution_part1(rows: List(String)) {
  let assert Ok(button_pattern) =
    regexp.from_string("Button .: X\\+(\\d+), Y\\+(\\d+)")

  let assert Ok(machine_pattern) =
    regexp.from_string("Prize: X\\=(\\d+), Y\\=(\\d+)")

  let machines =
    rows
    |> list.sized_chunk(3)
    |> list.map(parse_machine(_, machine_pattern, button_pattern))

  machines
  |> list.map(with_inputs)
  |> list.map(fn(pair) {
    let #(machine, inputs) = pair

    let solution =
      inputs
      |> yielder.filter(fn(input: Input) { input.position == machine.prize })
      |> yielder.to_list

    case solution {
      [] -> 0
      [solution] -> solution.cost
      _ -> panic
    }
  })
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn parse_machine(rows, machine_pattern, button_pattern) -> Machine {
  let assert [a, b, prize] = rows
  let a = parse_x_y_pattern(a, button_pattern)
  let b = parse_x_y_pattern(b, button_pattern)
  let prize = parse_x_y_pattern(prize, machine_pattern)

  Machine(a: Button(inc: a, cost: 3), b: Button(inc: b, cost: 1), prize:)
}

fn parse_x_y_pattern(line: String, pattern) -> Vec2 {
  let assert [match] = regexp.scan(pattern, line)
  let assert [Some(x), Some(y)] = match.submatches

  let assert Ok(x) = int.parse(x)
  let assert Ok(y) = int.parse(y)

  vec2.new(x, y)
}

fn button_presses(a: Button, b: Button, max: Int) -> Yielder(Input) {
  let a_presses = yielder.range(0, max)
  let b_presses = yielder.range(max, 0)

  permutations(a_presses, b_presses)
  |> yielder.map(fn(pair) {
    let #(a_presses, b_presses) = pair
    compute_input(a, b, a_presses, b_presses)
  })
}

fn compute_input(a: Button, b: Button, a_presses: Int, b_presses: Int) -> Input {
  let position =
    vec2.new(
      { a.inc.x * a_presses } + { b.inc.x * b_presses },
      { a.inc.y * a_presses } + { b.inc.y * b_presses },
    )
  let cost = { a.cost * a_presses } + { b.cost * b_presses }

  Input(a_presses:, b_presses:, position:, cost:)
}

fn with_inputs(machine: Machine) -> #(Machine, Yielder(Input)) {
  #(machine, button_presses(machine.a, machine.b, 100))
}

fn permutations(a: Yielder(a), b: Yielder(b)) -> Yielder(#(a, b)) {
  a |> yielder.flat_map(fn(x) { b |> yielder.map(fn(y) { #(x, y) }) })
}
