import gleam/option.{type Option, None, Some}
import gleam/int
import field/types.{type EveryVal, type OrVal, type RangeVal}
import util/weekday.{type Weekday}

pub type FieldVal {
  // ?
  Any

  // *
  All

  // 1
  // SUN
  Uni(value: Weekday)

  // 1-3
  // SUN-TUE
  Range(value: RangeVal(Weekday))

  // */2
  // 1/2
  // 1-3/2
  // SUN-TUE/2
  Every(value: EveryVal(Weekday))

  // 1,2
  // 1-3,5
  // 1-3/2,5
  // JAN-MAR/2,MAY
  Or(value: List(OrVal(Weekday)))

  // 0#1 
  // MON#1
  Index(index: Int, value: Weekday)

  // L
  // 0L 
  // MONL
  Last(value: Option(Weekday))
}

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> weekday.to_s(v)
    Range(v) -> types.range_to_s(v, weekday.to_s)
    Every(v) -> types.every_to_s(v, weekday.to_s)
    Or(v) -> types.or_to_s(v, weekday.to_s)
    Index(i, v) -> index_to_s(i, v)
    Last(v) -> last_to_s(v)
  }
}

// fn uni_to_s(d: Weekday) -> String {
//   weekday.to_s(d)
// }
//
// fn range_to_s(d: RangeVal(Weekday)) -> String {
//   weekday.to_s(d.from) <> "-" <> weekday.to_s(d.to)
// }
//
// fn every_to_s(d: EveryVal(Weekday)) -> String {
//   case d {
//     EveryAll(step) -> "*" <> "/" <> int.to_string(step)
//     EveryUni(v, step) -> weekday.to_s(v) <> "/" <> int.to_string(step)
//     EveryRange(v, step) -> range_to_s(v) <> "/" <> int.to_string(step)
//   }
// }
//
// fn or_to_s(d: List(OrVal(Weekday))) -> String {
//   list.map(d, fn(dd) {
//     case dd {
//       OrUni(v) -> uni_to_s(v)
//       OrRange(v) -> range_to_s(v)
//       OrEvery(v) -> every_to_s(v)
//     }
//   })
//   |> string.join(",")
// }

fn index_to_s(i: Int, d: Weekday) -> String {
  weekday.to_s(d) <> "#" <> int.to_string(i)
}

fn last_to_s(d: Option(Weekday)) -> String {
  case d {
    Some(v) -> weekday.to_s(v) <> "L"
    None -> "L"
  }
}
