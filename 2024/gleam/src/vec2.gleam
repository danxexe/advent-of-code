pub type Vec2 {
  Vec2(x: Int, y: Int)
}

pub const up = Vec2(0, -1)

pub const down = Vec2(0, 1)

pub const left = Vec2(-1, 0)

pub const right = Vec2(1, 0)

pub fn directions() -> List(Vec2) {
  [left, up, right, down]
}

pub fn new(x: Int, y: Int) -> Vec2 {
  Vec2(x, y)
}

pub fn from_tuple(t: #(Int, Int)) -> Vec2 {
  Vec2(t.0, t.1)
}

pub fn add(a: Vec2, b: Vec2) -> Vec2 {
  Vec2(a.x + b.x, a.y + b.y)
}
