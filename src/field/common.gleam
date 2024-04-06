import gleam/int
import gleam/list
import gleam/string
import gleam/order.{type Order, Eq, Lt}
import util/range.{type Range}
import gleam/result
import gleam/option.{type Option}

pub type RangeVal(a) {
  RangeVal(from: a, to: a)
}

pub type EveryVal(a) {
  EveryAll(step: Int)
  EveryUni(value: a, step: Int)
  EveryRange(value: RangeVal(a), step: Int)
}

pub type OrVal(a) {
  OrUni(value: a)
  OrRange(value: RangeVal(a))
  OrEvery(value: EveryVal(a))
}

pub fn to_s_range(d: RangeVal(a), f: fn(a) -> String) -> String {
  f(d.from) <> "-" <> f(d.to)
}

pub fn to_s_every(d: EveryVal(a), f: fn(a) -> String) -> String {
  case d {
    EveryAll(step) -> "*" <> "/" <> int.to_string(step)
    EveryUni(v, step) -> f(v) <> "/" <> int.to_string(step)
    EveryRange(v, step) -> to_s_range(v, f) <> "/" <> int.to_string(step)
  }
}

pub fn to_s_or(d: List(OrVal(a)), f: fn(a) -> String) -> String {
  list.map(d, fn(dd) {
    case dd {
      OrUni(v) -> f(v)
      OrRange(v) -> to_s_range(v, f)
      OrEvery(v) -> to_s_every(v, f)
    }
  })
  |> list.unique()
  |> string.join(",")
}

pub fn get_step(every: EveryVal(a)) -> Int {
  case every {
    EveryAll(step) -> step
    EveryUni(_, step) -> step
    EveryRange(_, step) -> step
  }
}

pub type FieldDef(a) {
  FieldDef(
    value_range: Range(a),
    value_compare: fn(a, a) -> Order,
    value_to_s: fn(a) -> String,
    every_step_range: Range(Int),
    index_range: Option(Range(Int)),
    last_range: Option(Range(Int)),
  )
}

pub fn validate_uni(
  value: a,
  field_def: FieldDef(a),
) -> Result(Nil, List(String)) {
  case range.include(field_def.value_range, value, field_def.value_compare) {
    True -> Ok(Nil)
    False ->
      Error([
        "value must in "
        <> range.to_s(field_def.value_range, field_def.value_to_s),
      ])
  }
}

pub fn validate_range(
  range: RangeVal(a),
  field_def: FieldDef(a),
) -> Result(Nil, List(String)) {
  case field_def.value_compare(range.from, range.to) {
    Lt | Eq -> Ok(Nil)
    _ -> Error(["range must from <= to"])
  }
}

pub fn validate_every(
  every: EveryVal(a),
  field_def: FieldDef(a),
) -> Result(Nil, List(String)) {
  let step_error =
    "step must in " <> range.to_s(field_def.every_step_range, int.to_string)
  let value_error =
    "value must in " <> range.to_s(field_def.value_range, field_def.value_to_s)

  case every {
    EveryAll(step) -> {
      case range.include(field_def.every_step_range, step, int.compare) {
        True -> Ok(Nil)
        False -> Error([step_error])
      }
    }
    EveryUni(v, step) -> {
      case
        range.include(field_def.value_range, v, field_def.value_compare),
        range.include(field_def.every_step_range, step, int.compare)
      {
        True, True -> Ok(Nil)
        False, True -> Error([value_error])
        True, False -> Error([step_error])
        False, False -> Error([step_error, value_error])
      }
    }
    EveryRange(v, step) -> {
      case
        validate_range(v, field_def),
        range.include(field_def.every_step_range, step, int.compare)
      {
        Ok(Nil), True -> Ok(Nil)
        Error(errors), True -> Error(errors)
        Ok(Nil), False -> Error([step_error])
        Error(errors), False -> Error([step_error, ..errors])
      }
    }
  }
}

pub fn validate_or(
  or_vals: List(OrVal(a)),
  field_def: FieldDef(a),
) -> Result(Nil, List(String)) {
  let fold_errors =
    list.fold(or_vals, [], fn(acc, it) {
      let it_errors =
        case it {
          OrUni(v) -> validate_uni(v, field_def)
          OrRange(v) -> validate_range(v, field_def)
          OrEvery(v) -> validate_every(v, field_def)
        }
        |> result.unwrap_error([])

      list.append(acc, it_errors)
    })

  case list.is_empty(fold_errors) {
    True -> Ok(Nil)
    False -> Error(fold_errors)
  }
}
