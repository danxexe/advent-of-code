import aoc
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/yielder.{type Yielder}

pub fn solution_part1(rows: List(String)) {
  solution(rows, 25)
}

pub fn solution_part2(rows: List(String)) {
  solution(rows, 75)
}

fn solution(rows: List(String), times: Int) {
  rows
  |> list.first()
  |> aoc.or_panic()
  |> string.split(" ")
  |> mutate(times)
  // |> list.length()
  |> io.debug
}

fn mutate(stones: List(String), times: Int) -> Int {
  do_mutate([], stones, 0, times)
  // |> list.reverse()
}

type Mutate {
  Mutate(val: String, times: Int)
}

type Mutation {
  Single(val: String)
  Multi(a: String, b: String)
}

fn do_mutate(
  mutate: List(Mutate),
  stones: List(String),
  acc: Int,
  times: Int,
) -> Int {
  // mutate |> io.debug
  // stones |> io.debug
  // acc |> io.debug
  // times |> io.debug
  // "---" |> io.debug

  case mutate {
    [] -> {
      case stones {
        [] -> acc
        stones -> {
          let assert [stone, ..rest] = stones
          rest |> list.length |> io.debug
          do_mutate([Mutate(stone, times)], rest, acc, times)
        }
      }
    }
    [mut, ..other] -> {
      case mut {
        Mutate(_, 0) -> do_mutate(other, stones, acc + 1, times)
        Mutate(stone, n) -> {
          let n = n - 1
          let mutate = case mutate_single(stone) {
            Single(s) -> [Mutate(s, n), ..other]
            Multi(s1, s2) -> [Mutate(s1, n), Mutate(s2, n), ..other]
          }
          do_mutate(mutate, stones, acc, times)
        }
      }
    }
  }
}

fn mutate_single(stone: String) -> Mutation {
  case stone {
    "0" -> Single("1")
    s -> {
      let len = string.length(s)
      case len % 2 {
        0 -> {
          let half = len / 2
          let left = string.slice(s, 0, half) |> trim()
          let right = string.slice(s, half, half) |> trim()
          Multi(left, right)
        }
        _ -> {
          let i = { int.parse(stone) |> aoc.or_panic } * 2024
          Single(int.to_string(i))
        }
      }
    }
  }
}

fn trim(str: String) -> String {
  case str {
    "0" -> "0"
    "0" <> rest -> trim(rest)
    _ -> str
  }
}
