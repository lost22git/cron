import gleam/option.{type Option, None, Some}
import gleam/int
import gleam/list
import gleam/string
import gleam/order.{Eq, Lt}
import field/types.{
  type EveryVal, type RangeVal, EveryAll, EveryRange, EveryUni, RangeVal,
}
import util/weekday.{type Weekday}
import gleam/result.{try}
import util/range

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

/// create **All**
///
/// ```gleam
/// let assert Ok(fieldVal) = all()
/// to_s(fieldVal) // *
/// ```
///
pub fn all() -> FieldVal {
  All
}

/// create **Any**
///
/// ```gleam
/// let assert Ok(fieldVal) = any()
/// to_s(fieldVal) // ?
/// ```
///
pub fn any() -> FieldVal {
  Any
}

/// create **Uni**
///
/// ```gleam
/// let assert Ok(fieldVal) = uni(1)
/// to_s(fieldVal) // 1
/// ```
///
pub fn uni(day: Int) -> Result(FieldVal, String) {
  use wd <- try(weekday.from_int(day))
  Ok(Uni(wd))
}

/// create **Uni**
///
/// ```gleam
/// let assert Ok(fieldVal) = uni_name("SUN")
/// to_s(fieldVal) // SUN
/// ```
///
pub fn uni_name(day: String) -> Result(FieldVal, String) {
  use wd <- try(weekday.from_name(day))
  Ok(Uni(wd))
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(fieldVal) = range(1, 4)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Int, to: Int) -> Result(FieldVal, String) {
  use from_wd <- try(weekday.from_int(from))
  use to_wd <- try(weekday.from_int(to))

  let r = Range(RangeVal(from_wd, to_wd))

  case from <= to {
    True -> Ok(r)
    _ -> Error("`" <> to_s(r) <> "`" <> " must from <= to")
  }
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(fieldVal) = range_name("SUN", "WED")
/// to_s(fieldVal) // SUN-WED
/// ```
///
pub fn range_name(from: String, to: String) -> Result(FieldVal, String) {
  use from_wd <- try(weekday.from_name(from))
  use to_wd <- try(weekday.from_name(to))

  let r = Range(RangeVal(from_wd, to_wd))

  case weekday.compare(from_wd, to_wd) {
    Lt | Eq -> Ok(r)
    _ -> Error("`" <> to_s(r) <> "`" <> " must from <= to")
  }
}

/// create **Index** (aka Hash) `#`
///
/// ```gleam
/// let assert Ok(fieldVal) = index(2, 1)
/// to_s(fieldVal) // 1#2
/// ```
///
pub fn index(index: Int, day: Int) -> Result(FieldVal, String) {
  use wd <- try(weekday.from_int(day))

  let i = Index(index, wd)

  let index_range = range.open_open(0, 6)
  case range.include(index_range, index, int.compare) {
    True -> Ok(i)
    _ ->
      Error(
        "`"
        <> to_s(i)
        <> "`"
        <> " index must in "
        <> range.to_s(index_range, int.to_string),
      )
  }
}

/// create **Index** (aka Hash) `#`
///
/// ```gleam
/// let assert Ok(fieldVal) = index_name(2,"SUN")
/// to_s(fieldVal) // SUN#2
/// ```
///
pub fn index_name(index: Int, day: String) -> Result(FieldVal, String) {
  use wd <- try(weekday.from_name(day))

  let i = Index(index, wd)

  let index_range = range.open_open(0, 6)
  case range.include(index_range, index, int.compare) {
    True -> Ok(i)
    _ ->
      Error(
        "`"
        <> to_s(i)
        <> "`"
        <> " index must in "
        <> range.to_s(index_range, int.to_string),
      )
  }
}

/// create **Last** `L`
/// 
/// ```gleam
/// let assert Ok(fieldVal) = last(Some(1))
/// to_s(fieldVal) // 1L
/// ```
///
/// ```gleam
/// let assert Ok(fieldVal) = last(None)
/// to_s(fieldVal) // L
/// ```
///
pub fn last(day: Option(Int)) -> Result(FieldVal, String) {
  case day {
    None -> Ok(Last(None))
    Some(v) -> {
      use wd <- try(weekday.from_int(v))
      Ok(Last(Some(wd)))
    }
  }
}

/// create **Last** `L`
/// 
/// ```gleam
/// let assert Ok(fieldVal) = last_name(Some("SUN"))
/// to_s(fieldVal) // SUNL
/// ```
///
/// ```gleam
/// let assert Ok(fieldVal) = last_name(None)
/// to_s(fieldVal) // L
/// ```
///
pub fn last_name(day: Option(String)) -> Result(FieldVal, String) {
  case day {
    None -> Ok(Last(None))
    Some(v) -> {
      use wd <- try(weekday.from_name(v))
      Ok(Last(Some(wd)))
    }
  }
}

/// build an **Every** `FieldVal` from another `FieldVal`
///
pub fn every(fval: FieldVal, step: Int) -> Result(FieldVal, String) {
  case fval {
    All -> Ok(Every(EveryAll(step)))
    Uni(v) -> Ok(Every(EveryUni(v, step)))
    Range(v) -> Ok(Every(EveryRange(v, step)))
    _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Every ( / )`")
  }
}

/// build an **Or** `FieldVal` from list of `FieldVal`
///
pub fn or(fvals: List(FieldVal)) -> Result(FieldVal, String) {
  use or_vals <- try(
    list.try_map(fvals, fn(fval) {
      case fval {
        Uni(v) -> Ok(OrUni(v))
        Range(v) -> Ok(OrRange(v))
        Every(v) -> Ok(OrEvery(v))
        Index(i, v) -> Ok(OrIndex(i, v))
        Last(v) -> Ok(OrLast(v))
        _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Or ( , )`")
      }
    }),
  )
  Ok(Or(or_vals))
}
