import gleam/option.{type Option, None, Some}
import gleam/int
import gleam/list
import gleam/string
import field/types.{type EveryVal, type RangeVal}
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

  // 1#1 
  // SUN#1
  Index(index: Int, value: Weekday)

  // L
  // 1L 
  // SUNL
  Last(value: Option(Weekday))

  // 1-3/2,5,1#1,1L
  // SUN-TUE/2,,SUN#1,SUNL
  Or(value: List(OrValForDayOfWeek))
}

pub type OrValForDayOfWeek {
  OrUni(value: Weekday)
  OrRange(value: RangeVal(Weekday))
  OrEvery(value: EveryVal(Weekday))
  OrIndex(index: Int, value: Weekday)
  OrLast(value: Option(Weekday))
}

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> weekday.to_s(v)
    Range(v) -> types.range_to_s(v, weekday.to_s)
    Every(v) -> types.every_to_s(v, weekday.to_s)
    Index(i, v) -> index_to_s(i, v)
    Last(v) -> last_to_s(v)
    Or(v) -> or_to_s(v, weekday.to_s)
  }
}

fn or_to_s(d: List(OrValForDayOfWeek), f: fn(Weekday) -> String) -> String {
  list.map(d, fn(dd) {
    case dd {
      OrUni(v) -> f(v)
      OrRange(v) -> types.range_to_s(v, f)
      OrEvery(v) -> types.every_to_s(v, f)
      OrIndex(i, v) -> index_to_s(i, v)
      OrLast(v) -> last_to_s(v)
    }
  })
  |> list.unique()
  |> string.join(",")
}

fn index_to_s(i: Int, d: Weekday) -> String {
  weekday.to_s(d) <> "#" <> int.to_string(i)
}

fn last_to_s(d: Option(Weekday)) -> String {
  case d {
    Some(v) -> weekday.to_s(v) <> "L"
    None -> "L"
  }
}
