import aoc
import bravo
import bravo/uset
import gleam/int
import gleam/list
import gleam/string

type Mutate {
  Mutate(val: String, times: Int)
}

type Mutation {
  Single(val: String)
  Multi(a: String, b: String)
}

type Cache =
  uset.USet(#(Mutate, Int))

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
}

fn mutate(stones: List(String), times: Int) -> Int {
  let assert Ok(cache) = uset.new("Cache", 1, bravo.Public)
  let count = do_mutate([], stones, 0, times, cache)
  uset.delete(cache)
  count
}

fn do_mutate(
  mutate: List(Mutate),
  stones: List(String),
  acc: Int,
  times: Int,
  cache: Cache,
) -> Int {
  case mutate {
    [] -> {
      case stones {
        [] -> acc
        stones -> {
          let assert [stone, ..rest] = stones
          do_mutate([Mutate(stone, times)], rest, acc, times, cache)
        }
      }
    }
    [mut, ..other] -> {
      case mut {
        Mutate(_, 0) -> do_mutate(other, stones, acc + 1, times, cache)
        Mutate(_, _) -> {
          let #(count, cache) = mutate_n_times(mut, cache)
          do_mutate(other, stones, acc + count, times, cache)
        }
      }
    }
  }
}

fn mutate_n_times(mutate: Mutate, cache: Cache) -> #(Int, Cache) {
  case uset.lookup(cache, mutate) {
    Ok(#(_, count)) -> #(count, cache)
    _ -> {
      let #(count, cache) = case mutate.times {
        0 -> #(1, cache)
        times -> {
          let mut = mutate_single(mutate.val)
          let n = times - 1
          case mut {
            Single(v) -> mutate_n_times(Mutate(v, n), cache)
            Multi(a, b) -> {
              let #(a, cache) = mutate_n_times(Mutate(a, n), cache)
              let #(b, cache) = mutate_n_times(Mutate(b, n), cache)

              #(a + b, cache)
            }
          }
        }
      }

      uset.insert(cache, [#(mutate, count)])

      #(count, cache)
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
