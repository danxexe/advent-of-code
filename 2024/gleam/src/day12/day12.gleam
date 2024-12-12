import aoc
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/yielder
import matrix2.{type Matrix2}
import vec2.{type Vec2, Vec2}

type Solution {
  Solution(garden: Map, regions: List(Region))
}

type Region {
  Region(
    plant: String,
    area: Int,
    perimeter: Int,
    fences: List(Fence),
    sides: Int,
  )
}

type Map =
  Matrix2(String)

type Fence =
  #(Vec2, String)

pub fn solution_part1(rows: List(String)) {
  let garden =
    rows
    |> list.map(fn(row) { row |> string.split("") })
    |> matrix2.from_list(" ")

  let assert Ok(solution) =
    Ok(Solution(garden:, regions: []))
    |> yielder.iterate(fn(solution) {
      case solution {
        Ok(solution) -> solution |> find_region()
        solution -> solution
      }
    })
    |> yielder.take_while(fn(solution) { solution |> result.is_ok() })
    |> yielder.last()

  let solution = case solution {
    Ok(solution) -> solution
    Error(solution) -> solution
  }

  solution.regions
  |> list.map(fn(region) { region.area * region.perimeter })
  |> list.reduce(int.add)
  |> aoc.or_panic
}

pub fn solution_part2(rows: List(String)) {
  let garden =
    rows
    |> list.map(fn(row) { row |> string.split("") })
    |> matrix2.from_list(" ")

  let assert Ok(solution) =
    Ok(Solution(garden:, regions: []))
    |> yielder.iterate(fn(solution) {
      case solution {
        Ok(solution) -> solution |> find_region()
        solution -> solution
      }
    })
    // |> yielder.take(4)
    |> yielder.take_while(fn(solution) { solution |> result.is_ok() })
    |> yielder.last()

  let solution = case solution {
    Ok(solution) -> solution
    Error(solution) -> solution
  }

  solution.regions
  |> list.map(fn(region) { region.area * region.sides })
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn merge_fences(fences) {
  fences
  |> list.group(fn(pair) {
    let #(_, fence) = pair
    fence
  })
  |> dict.map_values(fn(key, fences) {
    case key {
      "-" -> fences |> group_horizontal()
      "_" -> fences |> group_horizontal()
      "[" -> fences |> group_vertical()
      "]" -> fences |> group_vertical()
      _ -> panic
    }
  })
  |> dict.values
  |> list.reduce(int.add)
}

fn group_horizontal(fences) {
  fences
  |> list.group(fn(fence: Fence) { { fence.0 }.y })
  |> dict.map_values(fn(_, fences) {
    fences
    |> list.map(fn(fence: Fence) { { fence.0 }.x })
    |> sort_and_drop_contiguous()
  })
  |> dict.values
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn group_vertical(fences) {
  fences
  |> list.group(fn(fence: Fence) { { fence.0 }.x })
  |> dict.map_values(fn(_, fences) {
    fences
    |> list.map(fn(fence: Fence) { { fence.0 }.y })
    |> sort_and_drop_contiguous()
  })
  |> dict.values
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn sort_and_drop_contiguous(values) {
  values
  |> list.sort(int.compare)
  |> drop_contiguous()
  |> list.length
}

fn drop_contiguous(list) {
  do_drop_contiguous(list, [])
}

fn do_drop_contiguous(list, acc) {
  case list {
    [] -> panic
    [a] -> [a, ..acc]
    [a, b, ..rest] ->
      case { a + 1 } == b {
        True -> do_drop_contiguous([b, ..rest], acc)
        False -> do_drop_contiguous([b, ..rest], [a, ..acc])
      }
  }
}

const fill = "."

fn find_region(solution: Solution) -> Result(Solution, Solution) {
  let index =
    solution.garden
    |> matrix2.find_first_with(fn(v) { v != fill && v != " " })

  case index {
    Some(index) -> {
      let #(map, region) = solution.garden |> flood_fill(vec2.from_tuple(index))
      Ok(Solution(garden: map, regions: [region, ..solution.regions]))
    }
    None -> Error(solution)
  }
}

fn clear_previous_fill(map: Map) -> Map {
  map
  |> matrix2.sparse_map(fn(v) {
    case v {
      "." -> " "
      v -> v
    }
  })
}

fn flood_fill(map: Map, index: Vec2) {
  let map = map |> clear_previous_fill()
  let plant = map |> matrix2.getv(index)
  let neighbours = index |> get_neighbours()
  let fences = get_fences(map, plant, index)
  let perimeter = get_perimeter(map, plant, neighbours)
  let map = map |> matrix2.setv(index, fill)

  let region =
    Region(plant:, area: 1, perimeter: perimeter, fences: fences, sides: 0)

  let #(map, region) = do_flood_fill(map, region, neighbours)
  let sides = merge_fences(region.fences) |> aoc.or_panic

  #(map, Region(..region, sides: sides))
}

fn do_flood_fill(map: Map, region: Region, neighbours: List(Vec2)) {
  neighbours
  |> list.fold(#(map, region), fn(pair, pos) {
    let #(map, region) = pair
    let plant = map |> matrix2.getv(pos)
    let neighbours = pos |> get_neighbours()
    let fences = get_fences(map, plant, pos)

    case plant {
      plant if plant == region.plant -> {
        let map = map |> matrix2.setv(pos, fill)
        let perimeter = get_perimeter(map, plant, neighbours)

        let region =
          Region(
            ..region,
            area: region.area + 1,
            perimeter: region.perimeter + perimeter,
            fences: list.flatten([fences, region.fences]),
          )
        do_flood_fill(map, region, neighbours)
      }
      _ -> #(map, region)
    }
  })
}

fn direction_and_fence(dir: Vec2) -> Fence {
  let fence = case dir {
    d if d == vec2.up -> "-"
    d if d == vec2.down -> "_"
    d if d == vec2.left -> "["
    d if d == vec2.right -> "]"
    _ -> panic
  }

  #(dir, fence)
}

fn get_neighbours_and_fences(index: Vec2) -> List(Fence) {
  vec2.directions()
  |> list.map(direction_and_fence)
  |> list.map(fn(pair) {
    let #(dir, fence) = pair
    #(vec2.add(index, dir), fence)
  })
}

fn get_fences(map: Map, plant: String, index: Vec2) {
  index
  |> get_neighbours_and_fences()
  |> list.filter(fn(pair) {
    let #(pos, _) = pair
    is_inside_perimeter(map, plant, pos)
  })
}

fn get_neighbours(index) {
  vec2.directions()
  |> list.map(fn(dir) { vec2.add(index, dir) })
}

fn get_perimeter(map, plant, neighbours) -> Int {
  neighbours
  |> list.count(is_inside_perimeter(map, plant, _))
}

fn is_inside_perimeter(map, plant, pos) -> Bool {
  let v = map |> matrix2.getv(pos)
  !{ v == fill || v == plant }
}
