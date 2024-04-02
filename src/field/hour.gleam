import gleam/int
import field/types.{type EveryVal, type OrVal, type RangeVal}

pub type FieldVal {
  // ?
  Any

  // *
  All

  // 1
  Uni(value: Int)

  // 1-3
  Range(value: RangeVal(Int))

  // */2
  // 1/2
  // 1-3/2
  Every(value: EveryVal(Int))

  // 1,2
  // 1-3,5
  // 1-3/2,5
  Or(value: List(OrVal(Int)))
}

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> int.to_string(v)
    Range(v) -> types.range_to_s(v, int.to_string)
    Every(v) -> types.every_to_s(v, int.to_string)
    Or(v) -> types.or_to_s(v, int.to_string)
  }
}
