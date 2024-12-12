import aoc
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
  Region(plant: String, area: Int, perimeter: Int)
}

type Map =
  Matrix2(String)

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
  let perimeter = get_perimeter(map, plant, neighbours)
  let region = Region(plant:, area: 1, perimeter: perimeter)
  let map = map |> matrix2.setv(index, fill)

  do_flood_fill(map, region, index)
}

fn do_flood_fill(map: Map, region: Region, index: Vec2) {
  let neighbours = index |> get_neighbours()

  neighbours
  |> list.fold(#(map, region), fn(pair, pos) {
    let #(map, region) = pair
    let plant = map |> matrix2.getv(pos)
    let neighbours = pos |> get_neighbours()

    case plant {
      plant if plant == region.plant -> {
        let map = map |> matrix2.setv(pos, fill)
        let perimeter = get_perimeter(map, plant, neighbours)

        let region =
          Region(
            ..region,
            area: region.area + 1,
            perimeter: region.perimeter + perimeter,
          )
        do_flood_fill(map, region, pos)
      }
      _ -> #(map, region)
    }
  })
}

fn get_neighbours(index) {
  vec2.directions()
  |> list.map(fn(dir) { vec2.add(index, dir) })
}

fn get_perimeter(map, plant, neighbours) -> Int {
  neighbours
  |> list.count(fn(i) {
    let v = map |> matrix2.getv(i)
    !{ v == fill || v == plant }
  })
}
