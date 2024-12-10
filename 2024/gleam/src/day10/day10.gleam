import aoc
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/yielder.{type Yielder}
import matrix2.{type Matrix2}
import vec2.{type Vec2, Vec2}

type Node {
  Node(value: Int, index: Vec2, children: List(Node))
}

pub fn solution_part1(rows: List(String)) {
  solution(rows, list.unique)
}

pub fn solution_part2(rows: List(String)) {
  solution(rows, function.identity)
}

fn solution(rows: List(String), filter) {
  let map =
    rows
    |> list.map(fn(row) {
      row
      |> string.split("")
      |> list.map(int.parse)
      |> list.map(result.unwrap(_, -1))
    })
    |> matrix2.from_list(-1)

  let trailheads =
    map
    |> matrix2.filter_index(fn(v) { v == 0 })
    |> list.map(fn(index) {
      Node(value: 0, index: vec2.from_tuple(index), children: [])
    })

  trailheads
  |> list.map(navigate(map, _))
  |> list.map(leaf_nodes)
  |> list.map(filter)
  |> list.map(list.length)
  |> list.reduce(int.add)
  |> aoc.or_panic
}

fn navigate(map: Matrix2(Int), node: Node) -> Node {
  do_navigate(map, node, 1)
}

fn do_navigate(map: Matrix2(Int), node: Node, depth: Int) -> Node {
  case depth <= 9 {
    True -> {
      let children =
        get_children(map, node, depth)
        |> list.map(do_navigate(map, _, depth + 1))
      Node(..node, children: children)
    }
    False -> node
  }
}

fn get_children(map: Matrix2(Int), node: Node, depth: Int) -> List(Node) {
  vec2.directions()
  |> list.filter_map(fn(dir) {
    let pos = vec2.add(node.index, dir)
    let val = map |> matrix2.get(#(pos.x, pos.y))

    case val == depth {
      True -> {
        Ok(Node(value: depth, index: pos, children: []))
      }
      False -> Error(Nil)
    }
  })
}

fn is_trail_end(node: Node) -> Bool {
  case node.value {
    9 -> True
    _ -> False
  }
}

fn iterate_nodes(node: Node) -> Yielder(Node) {
  let children_iter =
    node.children
    |> yielder.from_list()
    |> yielder.flat_map(iterate_nodes)

  node
  |> yielder.single()
  |> yielder.append(children_iter)
}

fn leaf_nodes(node: Node) -> List(Node) {
  node
  |> iterate_nodes()
  |> yielder.filter(is_trail_end)
  |> yielder.to_list()
}
