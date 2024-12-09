import aoc
import gleam/int
import gleam/io
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
    |> compact()
    |> list.reverse()

  compact
  |> yield_blocks()
  |> yielder.index()
  |> yielder.map(fn(pair) { pair.0 * pair.1 })
  |> yielder.reduce(int.add)
  |> aoc.or_panic
}

fn parse_disk_map(id, entries) {
  case entries {
    [a] -> #(id + 1, [File(a, id:)])
    [a, b] -> #(id + 1, [File(a, id:), FreeSpace(b)])
    _ -> panic
  }
}

fn compact(entries) {
  do_compact(entries, [])
}

fn do_compact(entries, acc) {
  case entries {
    [] -> acc
    [entry, ..rest] ->
      case entry {
        File(size, id) -> {
          do_compact(rest, [File(size, id), ..acc])
        }
        FreeSpace(free_size) -> {
          case list.reverse(rest) {
            [] -> acc
            [FreeSpace(_), ..rest] ->
              do_compact([entry, ..list.reverse(rest)], acc)
            [File(size, id), ..rest] -> {
              case try_fit(free_size, size) {
                Exact ->
                  do_compact(list.reverse(rest), [File(free_size, id), ..acc])
                Fit(diff) ->
                  do_compact([FreeSpace(diff), ..list.reverse(rest)], [
                    File(size, id),
                    ..acc
                  ])
                NoFit(diff) ->
                  do_compact(list.reverse([File(diff, id), ..rest]), [
                    File(free_size, id),
                    ..acc
                  ])
              }
            }
          }
        }
      }
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
      FreeSpace(_) -> panic
      File(size, id) -> {
        id |> yielder.repeat() |> yielder.take(size)
      }
    }
  })
}

fn debug(entry: Entry) {
  case entry {
    File(size, id) -> string.repeat(int.to_string(id), size)
    FreeSpace(size) -> string.repeat(".", size)
  }
}

fn debug_entries(entries, acc) {
  let entries =
    entries
    |> list.map(debug)
    |> string.join("")

  let acc =
    acc
    |> list.reverse()
    |> list.map(debug)
    |> string.join("")

  acc <> entries
}
