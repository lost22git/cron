import field/types.{type EveryVal, type OrVal, type RangeVal}
import util/months.{type Month}

pub type FieldVal {
  // ?
  Any

  // *
  All

  // 1
  // JAN
  Uni(value: Month)

  // 1-3
  // JAN-MAR
  Range(value: RangeVal(Month))

  // */2
  // 1/2
  // 1-3/2
  // JAN-MAR/2
  Every(value: EveryVal(Month))

  // 1-3/2,5
  // JAN-MAR/2,MAY
  Or(value: List(OrVal(Month)))
}

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> months.to_s(v)
    Range(v) -> types.range_to_s(v, months.to_s)
    Every(v) -> types.every_to_s(v, months.to_s)
    Or(v) -> types.or_to_s(v, months.to_s)
  }
}
