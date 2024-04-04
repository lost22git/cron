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
pub fn uni(month: Int) -> Result(FieldVal, String) {
  use m <- try(months.from_int(month))
  Ok(Uni(m))
}

/// create **Uni**
///
/// ```gleam
/// let assert Ok(fieldVal) = uni_name("JAN")
/// to_s(fieldVal) // JAN
/// ```
///
pub fn uni_name(month: String) -> Result(FieldVal, String) {
  use m <- try(months.from_name(month))
  Ok(Uni(m))
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(fieldVal) = range(1, 4)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Int, to: Int) -> Result(FieldVal, String) {
  use from_m <- try(months.from_int(from))
  use to_m <- try(months.from_int(to))

  let r = Range(RangeVal(from_m, to_m))

  case from <= to {
    True -> Ok(r)
    _ -> {
      Error("`" <> to_s(r) <> "`" <> " must from <= to")
    }
  }
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(fieldVal) = range_name("JAN", "MAR")
/// to_s(fieldVal) // JAN-MAR
/// ```
///
pub fn range_name(from: String, to: String) -> Result(FieldVal, String) {
  use from_m <- try(months.from_name(from))
  use to_m <- try(months.from_name(to))

  let r = Range(RangeVal(from_m, to_m))

  case months.compare(from_m, to_m) {
    Lt | Eq -> Ok(r)
    _ -> {
      Error("`" <> to_s(r) <> "`" <> " must from <= to")
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
        _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Or ( , )`")
      }
    }),
  )
  Ok(Or(or_vals))
}
