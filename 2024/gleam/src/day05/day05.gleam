import aoc
import gleam/int
import gleam/list
import gleam/string

type Rule {
  Rule(before: Int, after: Int)
}

type Update {
  Update(pages: List(Int))
}

pub fn solution_part1(rows: List(String)) {
  let #(rules, updates) =
    rows
    |> list.split_while(fn(row) { row != "" })

  let rules =
    rules
    |> list.map(parse_rule)

  let assert Ok(sum) =
    updates
    |> list.filter(fn(row) { row != "" })
    |> list.map(parse_update)
    |> list.filter(is_correct_order(_, rules))
    |> list.map(get_middle_element)
    |> list.reduce(int.add)

  sum
}

fn parse_rule(row: String) -> Rule {
  let assert [l, r] = row |> string.split("|")
  let assert Ok(l) = int.parse(l)
  let assert Ok(r) = int.parse(r)

  Rule(l, r)
}

fn parse_update(row: String) -> Update {
  let pages =
    row
    |> string.split(",")
    |> list.map(aoc.to_int_or_panic)

  Update(pages)
}

fn is_correct_order(update: Update, rules: List(Rule)) -> Bool {
  rules
  |> list.filter(fn(rule) {
    list.contains(update.pages, rule.before)
    && list.contains(update.pages, rule.after)
  })
  |> list.map(fn(rule) {
    let found_pages =
      update.pages
      |> list.filter(fn(page) { list.contains([rule.before, rule.after], page) })

    found_pages == [rule.before, rule.after]
  })
  |> list.fold(True, fn(a, b) { a && b })
}

fn get_middle_element(update: Update) -> Int {
  let half = list.length(update.pages) / 2

  let assert [middle] =
    update.pages
    |> list.drop(half)
    |> list.take(1)

  middle
}
