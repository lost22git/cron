import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
import field/types.{
  type EveryVal, type OrVal, type RangeVal, EveryAll, EveryRange, EveryUni,
  OrEvery, OrRange, OrUni, RangeVal,
}

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

  // 1-3/2,5
  Or(value: List(OrVal(Int)))

  // L
  // L-2
  Last(value: Option(Int))
}

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> int.to_string(v)
    Range(v) -> types.range_to_s(v, int.to_string)
    Every(v) -> types.every_to_s(v, int.to_string)
    Or(v) -> types.or_to_s(v, int.to_string)
    Last(v) -> last_to_s(v)
  }
}

fn last_to_s(d: Option(Int)) -> String {
  case d {
    None -> "L"
    Some(v) -> "L" <> "-" <> int.to_string(v)
  }
}

/// create **All** `*`
///
/// ```gleam
/// let fieldVal = all()
/// to_s(fieldVal) // *
/// ```
///
pub fn all() -> FieldVal {
  All
}

/// create **Any** `?`
///
/// ```gleam
/// let fieldVal = any()
/// to_s(fieldVal) // ?
/// ```
///
pub fn any() -> FieldVal {
  Any
}

/// create **Uni**
///
/// ```gleam
/// let fieldVal = uni(1)
/// to_s(fieldVal) // 1
/// ```
///
pub fn uni(day: Int) -> FieldVal {
  Uni(day)
}

/// create **Range** `-`
///
/// ```gleam
/// let fieldVal = range(1, 4)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Int, to: Int) -> FieldVal {
  Range(RangeVal(from, to))
}

/// create **Last** `L`
/// 
/// ```gleam
/// let fieldVal = last(Some(1))
/// to_s(fieldVal) // L-1
/// ```
///
/// ```gleam
/// let fieldVal = last(None)
/// to_s(fieldVal) // L
/// ```
///
pub fn last(day: Option(Int)) -> FieldVal {
  Last(day)
}

/// build an **Every** `/` from another `FieldVal`
///
pub fn every(fval: FieldVal, step: Int) -> Result(FieldVal, String) {
  case fval {
    All -> Ok(Every(EveryAll(step)))
    Uni(v) -> Ok(Every(EveryUni(v, step)))
    Range(v) -> Ok(Every(EveryRange(v, step)))
    _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Every ( / )`")
  }
}

/// build an **Or** `,` from list of `FieldVal`
///
pub fn or(fvals: List(FieldVal)) -> Result(FieldVal, String) {
  use or_vals <- try(
    list.try_map(fvals, fn(fval) {
      case fval {
        Uni(v) -> Ok(OrUni(v))
        Range(v) -> Ok(OrRange(v))
        Every(v) -> Ok(OrEvery(v))
        _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Or ( , )`")
      }
    }),
  )
  Ok(Or(or_vals))
}
