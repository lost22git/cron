import gleam/order.{type Order, Eq, Lt}
import gleam/iterator.{type Iterator, type Step, Done, Next}
import gleam/option.{type Option, None, Some}

pub type Range(a) {
  Range(begin: a, end: a, close_begin: Bool, close_end: Bool)
}

/// create a `[b,e]` range
///
pub fn close_close(begin: a, end: a) -> Range(a) {
  Range(begin, end, True, True)
}

/// create a `[b,e)` range
///
pub fn close_open(begin: a, end: a) -> Range(a) {
  Range(begin, end, True, False)
}

/// create a `(b,e)` range
///
pub fn open_open(begin: a, end: a) -> Range(a) {
  Range(begin, end, False, False)
}

/// create a `(b,e]` range
///
pub fn open_close(begin: a, end: a) -> Range(a) {
  Range(begin, end, False, True)
}

/// test range include a value ?
///
/// ```gleam
/// close_close(1,10) |> include(1, int.compare)  // True
/// close_close(1,10) |> include(10, int.compare)  // True
/// close_close(1,10) |> include(0, int.compare)  // False
/// close_close(1,10) |> include(11, int.compare)  // False
/// ```
///
pub fn include(range: Range(a), value: a, compare_fn: fn(a, a) -> Order) -> Bool {
  case range.close_begin, range.close_end {
    True, True -> {
      case compare_fn(range.begin, value) {
        Lt | Eq ->
          case compare_fn(value, range.end) {
            Lt | Eq -> True
            _ -> False
          }
        _ -> False
      }
    }
    True, False -> {
      case compare_fn(range.begin, value) {
        Lt | Eq ->
          case compare_fn(value, range.end) {
            Lt -> True
            _ -> False
          }
        _ -> False
      }
    }
    False, False -> {
      case compare_fn(range.begin, value) {
        Lt ->
          case compare_fn(value, range.end) {
            Lt -> True
            _ -> False
          }
        _ -> False
      }
    }
    False, True -> {
      case compare_fn(range.begin, value) {
        Lt ->
          case compare_fn(value, range.end) {
            Lt | Eq -> True
            _ -> False
          }
        _ -> False
      }
    }
  }
}

/// range to string
///
/// ```gleam
/// close_close(1,10) |> to_s(int.to_string) // [1,10]
/// close_open(1,10) |> to_s(int.to_string) // [1,10)
/// open_open(1,10) |> to_s(int.to_string) // (1,10)
/// open_close(1,10) |> to_s(int.to_string) // (1,10]
/// ```
///
pub fn to_s(range: Range(a), f: fn(a) -> String) -> String {
  case range.close_begin, range.close_end {
    True, True -> "[" <> f(range.begin) <> "," <> f(range.end) <> "]"
    True, False -> "[" <> f(range.begin) <> "," <> f(range.end) <> ")"
    False, False -> "(" <> f(range.begin) <> "," <> f(range.end) <> ")"
    False, True -> "(" <> f(range.begin) <> "," <> f(range.end) <> "]"
  }
}

/// convert `Range` to iterator
///
pub fn iterator(
  range: Range(a),
  next_fn: fn(a) -> Option(a),
  compare_fn: fn(a, a) -> Order,
) -> Iterator(a) {
  case range.close_begin, range.close_end {
    True, True ->
      iterator.unfold(Some(range.begin), unfold_with(_, next_fn))
      |> iterator.take_while(fn(it) {
        compare_fn(it, range.end)
        |> is_le()
      })

    False, True ->
      iterator.unfold(next_fn(range.begin), unfold_with(_, next_fn))
      |> iterator.take_while(fn(it) {
        compare_fn(it, range.end)
        |> is_le()
      })

    False, False ->
      iterator.unfold(next_fn(range.begin), unfold_with(_, next_fn))
      |> iterator.take_while(fn(it) {
        compare_fn(it, range.end)
        |> is_lt()
      })

    True, False ->
      iterator.unfold(Some(range.begin), unfold_with(_, next_fn))
      |> iterator.take_while(fn(it) {
        compare_fn(it, range.end)
        |> is_lt()
      })
  }
}

fn unfold_with(
  cur_option: Option(a),
  next_fn: fn(a) -> Option(a),
) -> Step(a, Option(a)) {
  case cur_option {
    Some(v) -> Next(v, next_fn(v))
    None -> Done
  }
}

fn is_lt(order: Order) -> Bool {
  case order {
    Lt -> True
    _ -> False
  }
}

fn is_le(order: Order) -> Bool {
  case order {
    Lt | Eq -> True
    _ -> False
  }
}
