import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result.{try}
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
    Range(v) -> common.to_s_range(v, int.to_string)
    Every(v) -> common.to_s_every(v, int.to_string)
    Or(v) -> common.to_s_or(v, int.to_string)
    Last(v) -> to_s_last(v)
  }
}

fn to_s_last(d: Option(Int)) -> String {
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

/// get `FieldDef`
///
pub fn get_field_def() -> FieldDef(Int) {
  FieldDef(
    value_range: range.close_close(1, 31),
    value_compare: int.compare,
    value_to_s: int.to_string,
    every_step_range: range.close_close(1, 31),
    index_range: None,
    last_range: Some(range.close_close(1, 30)),
  )
}

/// validate `FieldVal`
/// 
pub fn validate(field_val: FieldVal) -> Result(FieldVal, List(String)) {
  let field_def = get_field_def()
  case field_val {
    All | Any -> Ok(Nil)
    Uni(_) -> Ok(Nil)
    Range(v) -> common.validate_range(v, field_def)
    Every(v) -> common.validate_every(v, field_def)
    Or(v) -> common.validate_or(v, field_def)
    Last(v) -> validate_last(v, field_def)
  }
  |> result.map(fn(_) { field_val })
  |> result.map_error(fn(errors) { [to_s(field_val), ..errors] })
}

fn validate_last(
  last_offset: Option(Int),
  field_def: FieldDef(Int),
) -> Result(Nil, List(String)) {
  let assert Some(last_range) = field_def.last_range
  case last_offset {
    None -> Ok(Nil)
    Some(offset) ->
      case range.include(last_range, offset, int.compare) {
        True -> Ok(Nil)
        False ->
          Error(["last offset must " <> range.to_s(last_range, int.to_string)])
      }
  }
}
