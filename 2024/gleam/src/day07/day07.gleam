import aoc
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder.{type Yielder}

type Equation {
  Equation(solution: Int, operands: List(Int))
}

type Operator {
  Add
  Mul
}

const possible_ops = [Add, Mul]

pub fn solution_part1(rows: List(String)) {
  rows
  |> list.map(parse_equation)
  |> list.filter(has_solution)
  |> list.map(fn(equation) { equation.solution })
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn parse_equation(row: String) -> Equation {
  let assert [solution, operands] = row |> string.split(":")
  let assert Ok(solution) = solution |> int.parse
  let operands =
    operands
    |> string.trim()
    |> string.split(" ")
    |> list.map(int.parse)
    |> list.map(aoc.or_panic)

  Equation(solution:, operands:)
}

fn combinations(
  a: Yielder(List(Operator)),
  b: List(Operator),
) -> Yielder(List(Operator)) {
  a
  |> yielder.flat_map(fn(x) {
    b
    |> yielder.from_list
    |> yielder.map(fn(y) { list.append(x, [y]) })
  })
}

fn combine_n_times(value, times) {
  value
  |> list.map(fn(op) { [op] })
  |> yielder.from_list()
  |> yielder.iterate(combinations(_, value))
  |> yielder.take(times)
  |> yielder.last()
  |> aoc.or_panic
}

fn has_solution(equation: Equation) {
  let solution_count =
    possible_ops
    |> combine_n_times(list.length(equation.operands) - 1)
    |> yielder.map(solve(equation, _))
    |> yielder.filter(fn(solution) { solution == equation.solution })
    |> yielder.length()

  solution_count > 0
}

fn solve(equation: Equation, operators: List(Operator)) {
  case equation.operands, operators {
    [result], [] -> result
    [left, rigth, ..rest_operands], [op, ..rest_operators] -> {
      let result = case op {
        Add -> left + rigth
        Mul -> left * rigth
      }
      solve(
        Equation(..equation, operands: [result, ..rest_operands]),
        rest_operators,
      )
    }
    _, _ -> panic
  }
}
