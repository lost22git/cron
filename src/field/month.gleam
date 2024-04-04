import util/months.{type Month}
import gleam/list
import gleam/result.{try}
import gleam/order.{Eq, Lt}
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
/// let assert Ok(m) = months.from_int(1)
/// let fieldVal = uni(m)
/// to_s(fieldVal) // 1
/// ```
///
pub fn uni(month: Month) -> FieldVal {
  Uni(month)
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(from) = months.from_int(1)
/// let assert Ok(to) = months.from_int(4)
/// let fieldVal = range(from, to)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Month, to: Month) -> FieldVal {
  Range(RangeVal(from, to))
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
