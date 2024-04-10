import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Lt}
import gleam/int
import gleam/result.{try}
import gleam/list
import gleam/string
import util/range.{type Range}
import util/str

pub type ExprKind {
  AllExpr
  AnyExpr
  AtExpr
  RngExpr
  EveryExpr
  OrExpr
  IndexExpr
  LastDayOfWeekExpr
  LastDayOfMonthExpr
}

pub type ExprVal(a) {
  // *
  All

  // ?
  Any

  // 1
  At(value: a)

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

pub type FieldName {
  Second
  Minute
  Hour
  DayOfMonth
  Month
  DayOfWeek
  Year
}

pub type FieldDef(a) {
  FieldDef(
    field_name: FieldName,
    expr_kinds: List(ExprKind),
    expr_kinds_in_every: List(ExprKind),
    expr_kinds_in_or: List(ExprKind),
    value_range: Range(a),
    value_compare: fn(a, a) -> Order,
    value_next: fn(a) -> Option(a),
    value_to_s: fn(a) -> String,
    value_from_s: fn(String) -> Result(a, List(String)),
    step_range: Range(Int),
    index_range: Option(Range(Int)),
    last_offset_range: Option(Range(Int)),
  )
}

pub type FieldVal(a) {
  FieldVal(expr_val: ExprVal(a), def: FieldDef(a))
}

/// `FieldVal` to string
///
pub fn to_s(field_val: FieldVal(a)) -> String {
  to_s_expr_val(field_val.expr_val, field_val.def)
}

fn to_s_expr_val(expr_val: ExprVal(a), def: FieldDef(a)) -> String {
  case expr_val {
    All -> "*"
    Any -> "?"
    At(val) -> def.value_to_s(val)
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
    At(_) -> AtExpr
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
  validate_inner(field_val.expr_val, field_val.def)
  |> result.map(fn(_) { field_val })
}

fn validate_inner(
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
    At(val) -> {
      case list.contains(def.expr_kinds, AtExpr) {
        False -> Error(["AtExpr is not allowed in the field"])
        True -> {
          case range.include(def.value_range, val, def.value_compare) {
            True -> Ok(Nil)
            False ->
              Error([
                "AtExpr value must be in "
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
                  validate_inner(val, def)
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
                validate_inner(inner_expr_val, def)
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

/// parse string as `FieldVal`
/// 
pub fn from_s(s: String, def: FieldDef(a)) -> Result(FieldVal(a), List(String)) {
  case string.split(s, ",") {
    [first] ->
      from_s_inner(str.remove_whitespaces(first), def)
      |> result.map(FieldVal(_, def))

    _ as items -> {
      list.try_map(items, fn(it) {
        from_s_inner(str.remove_whitespaces(it), def)
      })
      |> result.map(Or(_))
      |> result.map(FieldVal(_, def))
    }
  }
}

/// All `*`
/// Any `?`
///
fn from_s_inner(s: String, def: FieldDef(a)) -> Result(ExprVal(a), List(String)) {
  case s {
    "*" -> Ok(All)
    "?" -> Ok(Any)
    _ -> from_s_inner2(s, def)
  }
}

/// Index `#`
///
fn from_s_inner2(
  s: String,
  def: FieldDef(a),
) -> Result(ExprVal(a), List(String)) {
  let common_error = "Invalid expr: " <> s

  case string.split(s, "#") {
    [_] -> from_s_inner3(s, def)

    // 1#1
    [v, i] -> {
      use value <- try(def.value_from_s(v))
      use index <- try(
        int.parse(i)
        |> result.replace_error([common_error]),
      )
      Ok(Index(value, index))
    }

    _ -> Error([common_error])
  }
}

/// Last `L`
/// 
fn from_s_inner3(
  s: String,
  def: FieldDef(a),
) -> Result(ExprVal(a), List(String)) {
  let common_error = "Invalid expr: " <> s

  case string.split(s, "L") {
    [_] -> from_s_inner4(s, def)

    // "L"
    ["", ""] -> {
      case def.field_name {
        DayOfWeek -> Ok(LastDayOfWeek(None))
        DayOfMonth -> Ok(LastDayOfMonth(None))
        _ -> Error([common_error])
      }
    }

    // "1L"
    [v, ""] -> {
      use value <- try(def.value_from_s(v))
      Ok(LastDayOfWeek(Some(value)))
    }

    // "L-1"
    ["", v] -> {
      case string.split(v, "-") {
        ["", offset] -> {
          use offset_int <- try(
            int.parse(offset)
            |> result.replace_error([common_error]),
          )
          Ok(LastDayOfMonth(Some(offset_int)))
        }
        _ -> Error([common_error])
      }
    }

    _ -> Error([common_error])
  }
}

/// Every `/` 
/// Rng `-`
/// At
///
fn from_s_inner4(
  s: String,
  def: FieldDef(a),
) -> Result(ExprVal(a), List(String)) {
  let common_error = "Invalid expr: " <> s

  case string.split(s, "/") {
    [_] ->
      case string.split(s, "-") {
        // 1
        [_] -> {
          use value <- try(def.value_from_s(s))
          Ok(At(value))
        }

        // 1-2
        [f, t] -> {
          use from <- try(def.value_from_s(f))
          use to <- try(def.value_from_s(t))
          Ok(Rng(from, to))
        }

        _ -> Error([common_error])
      }

    [inner, step] -> {
      use inner_expr <- try(from_s_inner(inner, def))
      use step_int <- try(
        int.parse(step)
        |> result.replace_error([common_error]),
      )
      Ok(Every(inner_expr, step_int))
    }

    _ -> Error([common_error])
  }
}
