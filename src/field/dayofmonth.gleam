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
  case 1 <= day, day <= 31 {
    True, True -> Ok(Uni(day))
    _, _ -> Error("`" <> int.to_string(day) <> "`" <> " must in [1,31]")
  }
}

/// create **Range** `-`
///
/// ```gleam
/// let assert Ok(fieldVal) = range(1, 4)
/// to_s(fieldVal) // 1-4
/// ```
///
pub fn range(from: Int, to: Int) -> Result(FieldVal, String) {
  let r = Range(RangeVal(from, to))

  case 1 <= from, from <= to, to <= 31 {
    True, True, True -> Ok(r)
    _, _, _ -> Error("`" <> to_s(r) <> "`" <> " must in [1,31] and from <= to")
  }
}

/// create **Last** `L`
/// 
/// ```gleam
/// let assert Ok(fieldVal) = last(Some(1))
/// to_s(fieldVal) // L-1
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
      let l = Last(Some(v))
      case 1 <= v, v <= 30 {
        True, True -> Ok(l)
        _, _ -> {
          Error("`" <> to_s(l) <> "`" <> " must in [1,30]")
        }
      }
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
