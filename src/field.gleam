import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Lt}
import gleam/int
import gleam/result
import gleam/list
import gleam/string
import util/range.{type Range}

pub type ExprKind {
  AllExpr
  AnyExpr
  UniExpr
  RngExpr
  EveryExpr
  OrExpr
  IndexExpr
  LastDayOfWeekExpr
  LastDayOfMonthExpr
}

pub type FieldDef(a) {
  FieldDef(
    expr_kinds: List(ExprKind),
    expr_kinds_in_every: List(ExprKind),
    expr_kinds_in_or: List(ExprKind),
    value_range: Range(a),
    value_compare: fn(a, a) -> Order,
    value_to_s: fn(a) -> String,
    step_range: Range(Int),
    index_range: Option(Range(Int)),
    last_offset_range: Option(Range(Int)),
  )
}

pub type FieldVal(a) {
  FieldVal(expr_val: ExprVal(a), field_def: FieldDef(a))
}

pub type ExprVal(a) {
  // *
  All

  // ?
  Any

  // 1
  Uni(value: a)

  // 1-4
  Rng(from: a, to: a)

  // */2
  // 1/2
  // 1-4/2
  Every(value: ExprVal(a), step: Int)

  // 1,2
  // 1,1/2
  // 1,1/2,1-4/2
  Or(value: List(ExprVal(a)))

  // 1#1 for dayofweek
  Index(value: a, index: Int)

  // L
  // 1L for dayofweek
  LastDayOfWeek(value: Option(a))

  // L
  // L-1 for dayofmonth
  LastDayOfMonth(value: Option(Int))
}

/// `FieldVal` to string
///
pub fn to_s(field_val: FieldVal(a)) -> String {
  to_s_expr_val(field_val.expr_val, field_val.field_def)
}

fn to_s_expr_val(expr_val: ExprVal(a), def: FieldDef(a)) -> String {
  case expr_val {
    All -> "*"
    Any -> "?"
    Uni(val) -> def.value_to_s(val)
    Rng(from, to) -> def.value_to_s(from) <> "-" <> def.value_to_s(to)
    Every(val, step) -> to_s_expr_val(val, def) <> "/" <> int.to_string(step)
    Or(val) -> string.join(list.map(val, to_s_expr_val(_, def)), ",")
    Index(val, index) -> def.value_to_s(val) <> "#" <> int.to_string(index)
    LastDayOfWeek(Some(val)) -> def.value_to_s(val) <> "L"
    LastDayOfWeek(None) -> "L"
    LastDayOfMonth(Some(val)) -> "L-" <> int.to_string(val)
    LastDayOfMonth(None) -> "L"
  }
}

/// get `ExprKind` of the `ExprVal`
///
pub fn get_expr_kind(expr_val: ExprVal(a)) -> ExprKind {
  case expr_val {
    All -> AllExpr
    Any -> AnyExpr
    Uni(_) -> UniExpr
    Rng(_, _) -> RngExpr
    Every(_, _) -> EveryExpr
    Or(_) -> OrExpr
    Index(_, _) -> IndexExpr
    LastDayOfWeek(_) -> LastDayOfWeekExpr
    LastDayOfMonth(_) -> LastDayOfMonthExpr
  }
}

/// validate `FieldVal`
///
pub fn validate(field_val: FieldVal(a)) -> Result(FieldVal(a), List(String)) {
  validate_expr_val(field_val.expr_val, field_val.field_def)
  |> result.map(fn(_) { field_val })
}

fn validate_expr_val(
  expr_val: ExprVal(a),
  def: FieldDef(a),
) -> Result(Nil, List(String)) {
  case expr_val {
    All ->
      case list.contains(def.expr_kinds, AllExpr) {
        True -> Ok(Nil)
        False -> Error(["AllExpr `*` is not allowed in the field"])
      }
    Any ->
      case list.contains(def.expr_kinds, AnyExpr) {
        True -> Ok(Nil)
        False -> Error(["AnyExpr `?` is not allowed in the field"])
      }
    Uni(val) -> {
      case list.contains(def.expr_kinds, UniExpr) {
        False -> Error(["UniExpr is not allowed in the field"])
        True -> {
          case range.include(def.value_range, val, def.value_compare) {
            True -> Ok(Nil)
            False ->
              Error([
                "UniExpr value must be in "
                <> range.to_s(def.value_range, def.value_to_s),
              ])
          }
        }
      }
    }
    Rng(from, to) ->
      case list.contains(def.expr_kinds, RngExpr) {
        False -> Error(["RngExpr is not allowed in the field"])
        True ->
          case def.value_compare(from, to) {
            Lt | Eq -> Ok(Nil)
            _ -> Error(["RngExpr must from <= to"])
          }
      }
    Every(val, step) ->
      case list.contains(def.expr_kinds, EveryExpr) {
        False -> Error(["EveryExpr is not allowed in the field"])
        True ->
          case range.include(def.step_range, step, int.compare) {
            False ->
              Error([
                "EveryExpr step must in "
                <> range.to_s(def.step_range, int.to_string),
              ])
            True -> {
              let inner_expr_val_kind = get_expr_kind(val)
              case list.contains(def.expr_kinds_in_every, inner_expr_val_kind) {
                True ->
                  validate_expr_val(val, def)
                  |> result.map_error(list.map(_, fn(e) {
                    "EveryExpr inner expr error: " <> e
                  }))
                False ->
                  Error([
                    "EveryExpr include unsupported expr kind: "
                    <> string.inspect(inner_expr_val_kind)
                    <> " in the field",
                  ])
              }
            }
          }
      }
    Or(val) ->
      case list.contains(def.expr_kinds, OrExpr) {
        False -> Error(["OrExpr is not allowed in the field"])
        True ->
          list.try_map(val, fn(inner_expr_val) {
            let inner_expr_val_kind = get_expr_kind(inner_expr_val)
            case list.contains(def.expr_kinds_in_or, inner_expr_val_kind) {
              True ->
                validate_expr_val(inner_expr_val, def)
                |> result.map_error(list.map(_, fn(e) {
                  "OrExpr inner expr error: " <> e
                }))
              False ->
                Error([
                  "OrExpr include unsupported expr kind: "
                  <> string.inspect(inner_expr_val_kind)
                  <> " in the field",
                ])
            }
          })
          |> result.map(fn(_) { Nil })
      }
    Index(val, index) ->
      case list.contains(def.expr_kinds, IndexExpr) {
        False -> Error(["OrExpr is not allowed in the field"])
        True -> {
          let assert Some(index_range) = def.index_range
          let value_range_error =
            "OrExpr value must in "
            <> range.to_s(def.value_range, def.value_to_s)
          let index_range_error =
            "OrExpr index must in " <> range.to_s(index_range, int.to_string)
          case
            range.include(def.value_range, val, def.value_compare),
            range.include(index_range, index, int.compare)
          {
            True, True -> Ok(Nil)
            False, True -> Error([value_range_error])
            False, False -> Error([value_range_error, index_range_error])
            True, False -> Error([index_range_error])
          }
        }
      }
    LastDayOfWeek(val) ->
      case list.contains(def.expr_kinds, LastDayOfWeekExpr) {
        False -> Error(["LastDayOfWeekExpr is not allowed in the field"])
        True ->
          case val {
            None -> Ok(Nil)
            Some(v) ->
              case range.include(def.value_range, v, def.value_compare) {
                True -> Ok(Nil)
                False ->
                  Error([
                    "LastDayOfWeekExpr value must in "
                    <> range.to_s(def.value_range, def.value_to_s),
                  ])
              }
          }
      }
    LastDayOfMonth(val) ->
      case list.contains(def.expr_kinds, LastDayOfMonthExpr) {
        False -> Error(["LastDayOfMonthExpr is not allowed in the field"])
        True ->
          case val {
            None -> Ok(Nil)
            Some(offset) -> {
              let assert Some(last_offset_range) = def.last_offset_range
              case range.include(last_offset_range, offset, int.compare) {
                True -> Ok(Nil)
                False ->
                  Error([
                    "LastDayOfWeekExpr offset must in "
                    <> range.to_s(last_offset_range, int.to_string),
                  ])
              }
            }
          }
      }
  }
}
