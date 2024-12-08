import gleam/dict
import gleam/int
import gleam/list
import gleam/string
import gleam/yielder
import matrix2

type Antenna {
  Antenna(position: #(Int, Int), frequency: String)
}

pub fn solution_part1(rows: List(String)) {
  let map = rows |> parse_map()

  map
  |> group_by_frequency()
  |> dict.values()
  |> list.flat_map(antenna_pairs)
  |> list.flat_map(antinodes_v1)
  |> list.unique()
  |> list.filter(is_in_bounds(_, #(map.width, map.heigth)))
  |> list.length()
}

pub fn solution_part2(rows: List(String)) {
  let map = rows |> parse_map()

  map
  |> group_by_frequency()
  |> dict.values()
  |> list.flat_map(antenna_pairs)
  |> list.flat_map(antinodes_v2(_, #(map.width, map.heigth)))
  |> list.unique()
  |> list.length()
}

fn parse_map(rows) {
  rows
  |> list.map(string.split(_, ""))
  |> matrix2.from_list(".")
}

fn group_by_frequency(map) {
  map
  |> matrix2.filter_index(fn(val) { val != "." })
  |> list.map(fn(index) {
    Antenna(position: index, frequency: matrix2.get(map, index))
  })
  |> list.group(fn(antenna) { antenna.frequency })
}

fn antenna_pairs(antennas: List(Antenna)) {
  list.combination_pairs(antennas)
}

fn antinodes_v1(antenna_pair: #(Antenna, Antenna)) {
  let #(a, b) = antenna_pair
  let distance = distance(antenna_pair)
  let direction = direction(antenna_pair)

  [
    vec_sum(a.position, vec_mult(distance, direction)),
    vec_sum(b.position, vec_mult(distance, vec_invert(direction))),
  ]
}

fn antinodes_v2(antenna_pair: #(Antenna, Antenna), bounds) {
  let #(a, b) = antenna_pair
  let dist = distance(antenna_pair)
  let dir = direction(antenna_pair)

  let behind =
    nodes_in_line(a.position, vec_mult(dist, dir))
    |> yielder.take_while(is_in_bounds(_, bounds))
  let in_front =
    nodes_in_line(b.position, vec_mult(dist, vec_invert(dir)))
    |> yielder.take_while(is_in_bounds(_, bounds))

  yielder.interleave(behind, in_front)
  |> yielder.to_list()
}

fn nodes_in_line(v, dist) {
  yielder.iterate(#(v, dist), fn(pos_dist) {
    let #(pos, dist) = pos_dist
    #(vec_sum(pos, dist), dist)
  })
  |> yielder.map(fn(pair) { pair.0 })
}

fn distance(antenna_pair: #(Antenna, Antenna)) {
  let #(a, b) = antenna_pair
  #(
    int.absolute_value(a.position.0 - b.position.0),
    int.absolute_value(a.position.1 - b.position.1),
  )
}

fn direction(antenna_pair: #(Antenna, Antenna)) {
  let #(a, b) = antenna_pair
  #(
    normalize(a.position.0 - b.position.0),
    normalize(a.position.1 - b.position.1),
  )
}

fn normalize(v: Int) -> Int {
  case v {
    0 -> 0
    v if v < 0 -> -1
    _ -> 1
  }
}

fn vec_sum(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(a.0 + b.0, a.1 + b.1)
}

fn vec_mult(a: #(Int, Int), b: #(Int, Int)) -> #(Int, Int) {
  #(a.0 * b.0, a.1 * b.1)
}

fn vec_invert(v: #(Int, Int)) -> #(Int, Int) {
  #(-v.0, -v.1)
}

fn is_in_bounds(position: #(Int, Int), bounds: #(Int, Int)) -> Bool {
  position.0 >= 0
  && position.1 >= 0
  && position.0 < bounds.0
  && position.1 < bounds.1
}
