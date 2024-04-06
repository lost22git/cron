import gleam/option.{type Option, None, Some}
import gleam/int
import gleam/list
import gleam/string
import field/common.{
  type EveryVal, type FieldDef, type RangeVal, EveryAll, EveryRange, EveryUni,
  FieldDef, RangeVal,
}
import util/weekday.{type Weekday}
import util/range
import gleam/result.{try}

pub type OrValForDayOfWeek {
  OrUni(value: Weekday)
  OrRange(value: RangeVal(Weekday))
  OrEvery(value: EveryVal(Weekday))
  OrIndex(index: Int, value: Weekday)
  OrLast(value: Option(Weekday))
}

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

pub fn to_s(d: FieldVal) -> String {
  case d {
    Any -> "?"
    All -> "*"
    Uni(v) -> weekday.to_s(v)
    Range(v) -> common.to_s_range(v, weekday.to_s)
    Every(v) -> common.to_s_every(v, weekday.to_s)
    Index(i, v) -> to_s_index(i, v)
    Last(v) -> to_s_last(v)
    Or(v) -> to_s_or(v, weekday.to_s)
  }
}

fn to_s_or(d: List(OrValForDayOfWeek), f: fn(Weekday) -> String) -> String {
  list.map(d, fn(dd) {
    case dd {
      OrUni(v) -> f(v)
      OrRange(v) -> common.to_s_range(v, f)
      OrEvery(v) -> common.to_s_every(v, f)
      OrIndex(i, v) -> to_s_index(i, v)
      OrLast(v) -> to_s_last(v)
    }
  })
  |> list.unique()
  |> string.join(",")
}

fn to_s_index(i: Int, d: Weekday) -> String {
  weekday.to_s(d) <> "#" <> int.to_string(i)
}

fn to_s_last(d: Option(Weekday)) -> String {
  case d {
    Some(v) -> weekday.to_s(v) <> "L"
    None -> "L"
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
/// let assert Ok(wd) = weekday.from_int(1)
/// let fieldVal = uni(wd)
/// to_s(fieldVal) // 1
/// ```
///
pub fn uni(day: Weekday) -> FieldVal {
  Uni(day)
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(from) = weekday.from_int(1)
/// let assert Ok(to) = weekday.from_int(4)
/// let fieldVal = range(from, to)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Weekday, to: Weekday) -> FieldVal {
  Range(RangeVal(from, to))
}

/// create **Index** (aka Hash) `#`
///
/// ```gleam
/// let assert Ok(wd) = weekday.from_int(1)
/// let fieldVal = index(2, wd)
/// to_s(fieldVal) // 1#2
/// ```
///
pub fn index(index: Int, day: Weekday) -> FieldVal {
  Index(index, day)
}

/// create **Last** `L`
/// 
/// ```gleam
/// let assert Ok(wd) = weekday.from_int(1)
/// let fieldVal = last(wd)
/// to_s(fieldVal) // 1L
/// ```
///
/// ```gleam
/// let fieldVal = last(None)
/// to_s(fieldVal) // L
/// ```
///
pub fn last(day: Option(Weekday)) -> FieldVal {
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
        Index(i, v) -> Ok(OrIndex(i, v))
        Last(v) -> Ok(OrLast(v))
        _ -> Error("`" <> to_s(fval) <> "`" <> " not support `Or ( , )`")
      }
    }),
  )
  Ok(Or(or_vals))
}

/// get `FieldDef`
///
pub fn get_field_def() -> FieldDef(Weekday) {
  FieldDef(
    value_range: weekday.range(),
    value_compare: weekday.compare,
    value_to_s: weekday.to_s,
    every_step_range: range.close_close(1, list.length(weekday.names)),
    index_range: Some(range.close_close(1, 5)),
    last_range: None,
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
    Index(i, _) -> validate_index(i, field_def)
    Last(_) -> Ok(Nil)
    Or(v) -> validate_or(v, field_def)
  }
  |> result.map(fn(_) { field_val })
  |> result.map_error(fn(errors) { [to_s(field_val), ..errors] })
}

fn validate_index(
  index: Int,
  field_def: FieldDef(Weekday),
) -> Result(Nil, List(String)) {
  let assert Some(index_range) = field_def.index_range
  case range.include(index_range, index, int.compare) {
    True -> Ok(Nil)
    False -> Error(["index must " <> range.to_s(index_range, int.to_string)])
  }
}

fn validate_or(
  or_vals: List(OrValForDayOfWeek),
  field_def: FieldDef(Weekday),
) -> Result(Nil, List(String)) {
  let fold_errors =
    list.fold(or_vals, [], fn(acc, it) {
      let it_errors =
        case it {
          OrUni(_) -> Ok(Nil)
          OrRange(v) -> common.validate_range(v, field_def)
          OrEvery(v) -> common.validate_every(v, field_def)
          OrIndex(i, _) -> validate_index(i, field_def)
          OrLast(_) -> Ok(Nil)
        }
        |> result.unwrap_error([])

      list.append(acc, it_errors)
    })

  case list.is_empty(fold_errors) {
    True -> Ok(Nil)
    False -> Error(fold_errors)
  }
}
