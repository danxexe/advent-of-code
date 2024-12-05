import aoc
import gleam/bool
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
  let #(rules, updates) = rows |> list.split_while(fn(row) { row != "" })
  let rules = rules |> list.map(parse_rule)

  updates
  |> list.filter(fn(row) { row != "" })
  |> list.map(parse_update)
  |> list.filter(is_correct_order(_, rules))
  |> list.map(get_middle_element)
  |> list.reduce(int.add)
  |> aoc.or_panic
}

pub fn solution_part2(rows: List(String)) {
  let #(rules, updates) = rows |> list.split_while(fn(row) { row != "" })
  let rules = rules |> list.map(parse_rule)

  updates
  |> list.filter(fn(row) { row != "" })
  |> list.map(parse_update)
  |> reject(is_correct_order(_, rules))
  |> list.map(reorder(_, rules))
  |> list.map(reorder(_, rules))
  |> list.map(get_middle_element)
  |> list.reduce(int.add)
  |> aoc.or_panic
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
  |> list.filter(rule_is_applicable(update, _))
  |> list.map(fn(rule) -> Bool {
    update.pages
    |> get_pages_for_rule(rule)
    |> order_matches_rule(rule)
  })
  |> list.fold(True, fn(a, b) { a && b })
}

fn rule_is_applicable(update: Update, rule: Rule) -> Bool {
  list.contains(update.pages, rule.before)
  && list.contains(update.pages, rule.after)
}

fn get_pages_for_rule(pages: List(Int), rule: Rule) -> List(Int) {
  pages
  |> list.filter(fn(page) { list.contains([rule.before, rule.after], page) })
}

fn order_matches_rule(pages: List(Int), rule: Rule) {
  pages == [rule.before, rule.after]
}

fn get_middle_element(update: Update) -> Int {
  let half = list.length(update.pages) / 2

  let assert [middle] =
    update.pages
    |> list.drop(half)
    |> list.take(1)

  middle
}

fn reject(list: List(t), filter: fn(t) -> Bool) {
  list.filter(list, fn(val) { val |> filter() |> bool.negate() })
}

fn reorder(update: Update, rules: List(Rule)) -> Update {
  rules
  |> list.fold(update, reorder_for_rule)
}

fn reorder_for_rule(update: Update, rule: Rule) -> Update {
  let is_sorted =
    update.pages
    |> get_pages_for_rule(rule)
    |> order_matches_rule(rule)

  let is_applicable = rule_is_applicable(update, rule)

  case is_applicable, is_sorted {
    False, _ -> update
    True, True -> update
    True, False -> {
      case list.pop(update.pages, fn(page) { page == rule.before }) {
        Error(_) -> update
        Ok(#(val_to_swap, pages)) -> {
          let #(before, after) =
            pages |> list.split_while(fn(val) { val != rule.after })

          Update(pages: list.flatten([before, [val_to_swap], after]))
        }
      }
    }
  }
}
