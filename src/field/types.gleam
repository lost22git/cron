import gleam/int
import gleam/list
import gleam/string

pub type RangeVal(a) {
  RangeVal(from: a, to: a)
}

pub type EveryVal(a) {
  EveryAll(step: Int)
  EveryUni(value: a, step: Int)
  EveryRange(value: RangeVal(a), step: Int)
}

pub type OrVal(a) {
  OrUni(value: a)
  OrRange(value: RangeVal(a))
  OrEvery(value: EveryVal(a))
}

pub fn range_to_s(d: RangeVal(a), f: fn(a) -> String) -> String {
  f(d.from) <> "-" <> f(d.to)
}

pub fn every_to_s(d: EveryVal(a), f: fn(a) -> String) -> String {
  case d {
    EveryAll(step) -> "*" <> "/" <> int.to_string(step)
    EveryUni(v, step) -> f(v) <> "/" <> int.to_string(step)
    EveryRange(v, step) -> range_to_s(v, f) <> "/" <> int.to_string(step)
  }
}

pub fn or_to_s(d: List(OrVal(a)), f: fn(a) -> String) -> String {
  list.map(d, fn(dd) {
    case dd {
      OrUni(v) -> f(v)
      OrRange(v) -> range_to_s(v, f)
      OrEvery(v) -> every_to_s(v, f)
    }
  })
  |> string.join(",")
}
