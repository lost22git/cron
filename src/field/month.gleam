import util/months.{type Month}
import gleam/list
import gleam/result.{try}
import gleam/option.{None}
import field/common.{
  type EveryVal, type FieldDef, type OrVal, type RangeVal, EveryAll, EveryRange,
  EveryUni, FieldDef, OrEvery, OrRange, OrUni, RangeVal,
}
import util/range

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
    Range(v) -> common.to_s_range(v, months.to_s)
    Every(v) -> common.to_s_every(v, months.to_s)
    Or(v) -> common.to_s_or(v, months.to_s)
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

/// get `FieldDef`
///
pub fn get_field_def() -> FieldDef(Month) {
  FieldDef(
    value_range: months.range(),
    value_compare: months.compare,
    value_to_s: months.to_s,
    every_step_range: range.close_close(1, list.length(months.names)),
    index_range: None,
    last_range: None,
  )
}

/// validate `FieldVal`
/// 
pub fn validate(field_val: FieldVal) -> Result(FieldVal, List(String)) {
  let field_def = get_field_def()
  case field_val {
    All | Any -> Ok(Nil)
    Uni(v) -> common.validate_uni(v, field_def)
    Range(v) -> common.validate_range(v, field_def)
    Every(v) -> common.validate_every(v, field_def)
    Or(v) -> common.validate_or(v, field_def)
  }
  |> result.map(fn(_) { field_val })
  |> result.map_error(fn(errors) { [to_s(field_val), ..errors] })
}
