import aoc
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder

type Entry {
  File(size: Int, id: Int)
  FreeSpace(size: Int)
}

type SizeFit {
  Exact
  Fit(diff: Int)
  NoFit(diff: Int)
}

pub fn solution_part1(rows: List(String)) {
  let assert Ok(row) = rows |> list.first()

  let #(_, map) =
    row
    |> string.split("")
    |> list.map(int.parse)
    |> list.map(aoc.or_panic)
    |> list.sized_chunk(2)
    |> list.map_fold(0, parse_disk_map)

  let compact =
    map
    |> list.flatten()
    |> compact(compact_split)
    |> list.reverse()

  compact
  |> yield_blocks()
  |> yielder.index()
  |> yielder.map(fn(pair) { pair.0 * pair.1 })
  |> yielder.reduce(int.add)
  |> aoc.or_panic
}

pub fn solution_part2(rows: List(String)) {
  let assert Ok(row) = rows |> list.first()

  let #(_, map) =
    row
    |> string.split("")
    |> list.map(int.parse)
    |> list.map(aoc.or_panic)
    |> list.sized_chunk(2)
    |> list.map_fold(0, parse_disk_map)

  let flat_map =
    map
    |> list.flatten()

  let files =
    flat_map
    |> list.filter(fn(entry) {
      case entry {
        File(_, _) -> True
        _ -> False
      }
    })
    |> list.reverse()

  let compact =
    files
    |> list.fold(flat_map, try_to_fit)

  compact
  |> yield_blocks()
  |> yielder.index()
  |> yielder.map(fn(pair) { pair.0 * pair.1 })
  |> yielder.reduce(int.add)
  |> aoc.or_panic
}

fn try_to_fit(map: List(Entry), file: Entry) {
  let assert File(file_size, _) = file
  let #(before, after) =
    map
    |> list.split_while(fn(entry) {
      case entry {
        FreeSpace(size) if size >= file_size -> False
        _ -> True
      }
    })

  case before, after {
    _, [] -> map
    before, [space, ..after] -> {
      case try_fit(space.size, file.size) {
        Exact ->
          list.flatten([before, [file], after])
          |> replace_last_occurrence(file, FreeSpace(file.size))
        Fit(diff) ->
          list.flatten([before, [file, FreeSpace(diff)], after])
          |> replace_last_occurrence(file, FreeSpace(file.size))
        NoFit(_) -> map
      }
    }
  }
}

fn replace_last_occurrence(entries, value, replacement) {
  let #(before, after) =
    entries
    |> list.reverse()
    |> list.split_while(fn(entry) { entry != value })

  case before, after {
    before, [] -> [before, [replacement], after]
    before, [_, ..after] -> [before, [replacement], after]
  }
  |> list.flatten
  |> list.reverse()
}

fn parse_disk_map(id, entries) {
  case entries {
    [a] -> #(id + 1, [File(a, id:)])
    [a, b] -> #(id + 1, [File(a, id:), FreeSpace(b)])
    _ -> panic
  }
}

fn compact(entries, compact_fn: CompactFn) {
  do_compact(entries, [], [], compact_fn)
}

type CompactFn =
  fn(Int, Int, Int, List(Entry), List(Entry), List(Entry)) ->
    #(List(Entry), List(Entry), List(Entry))

fn do_compact(entries, acc, not_moved, compact_fn: CompactFn) {
  case entries {
    [] -> list.flatten([list.reverse(not_moved), acc])
    [entry, ..rest] ->
      case entry {
        File(size, id) ->
          do_compact(rest, [File(size, id), ..acc], not_moved, compact_fn)
        FreeSpace(free_size) -> {
          case list.reverse(rest) {
            [] -> list.flatten([list.reverse(not_moved), acc])
            [FreeSpace(_), ..rest] ->
              do_compact(
                [entry, ..list.reverse(rest)],
                acc,
                not_moved,
                compact_fn,
              )
            [File(size, id), ..rest] -> {
              let fit = compact_fn(free_size, size, id, rest, acc, not_moved)
              do_compact(fit.0, fit.1, fit.2, compact_fn)
            }
          }
        }
      }
  }
}

fn compact_split(free_size, size, id, rest, acc, not_moved) {
  case try_fit(free_size, size) {
    Exact -> #(list.reverse(rest), [File(free_size, id), ..acc], not_moved)
    Fit(diff) -> #(
      [FreeSpace(diff), ..list.reverse(rest)],
      [File(size, id), ..acc],
      not_moved,
    )
    NoFit(diff) -> #(
      list.reverse([File(diff, id), ..rest]),
      [File(free_size, id), ..acc],
      not_moved,
    )
  }
}

fn try_fit(free_size, size) {
  case free_size - size {
    diff if diff == 0 -> Exact
    diff if diff > 0 -> Fit(diff)
    diff -> NoFit(int.absolute_value(diff))
  }
}

fn yield_blocks(files) {
  files
  |> yielder.from_list()
  |> yielder.flat_map(fn(file: Entry) {
    case file {
      FreeSpace(size) -> 0 |> yielder.repeat() |> yielder.take(size)
      File(size, id) -> {
        id |> yielder.repeat() |> yielder.take(size)
      }
    }
  })
}
