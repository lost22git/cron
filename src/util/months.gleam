import gleam/int
import gleam/list
import gleam/string
import gleam/order.{type Order}
import gleam/option.{type Option, None, Some}
import util/range

pub opaque type Month {
  MonthNumber(value: Int)
  MonthName(value: String)
}

/// names of `Month`
///
pub const names = [
  "JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV",
  "DEC",
]

/// get `Range` of `Month`
///
pub fn range() -> range.Range(Month) {
  let assert Ok(from) = from_int(1)
  let assert Ok(to) = from_int(list.length(names))
  range.close_close(from, to)
}

/// get int `Range` of `Month`
///
pub fn int_range() -> range.Range(Int) {
  range.close_close(1, list.length(names))
}

/// create `Month` from a int value
/// 
/// | int | name |
/// |:---:|:----:|
/// | 1 | JAN |
/// | 2 | FEB |
/// | 3 | MAR |
/// | 4 | APR |
/// | 5 | MAY |
/// | 6 | JUN |
/// | 7 | JUL |
/// | 8 | AUG |
/// | 9 | SEP |
/// | 10 | OCT |
/// | 11 | NOV |
/// | 12 | DEC |
///
pub fn from_int(value: Int) -> Result(Month, String) {
  let r = int_range()
  case range.include(r, value, int.compare) {
    True -> Ok(MonthNumber(value))
    _ ->
      Error(
        "`"
        <> int.to_string(value)
        <> "`"
        <> " must in "
        <> range.to_s(r, int.to_string),
      )
  }
}

/// create `Month` from a string name
/// 
/// | int | name |
/// |:---:|:----:|
/// | 1 | JAN |
/// | 2 | FEB |
/// | 3 | MAR |
/// | 4 | APR |
/// | 5 | MAY |
/// | 6 | JUN |
/// | 7 | JUL |
/// | 8 | AUG |
/// | 9 | SEP |
/// | 10 | OCT |
/// | 11 | NOV |
/// | 12 | DEC |
///
pub fn from_name(name: String) -> Result(Month, String) {
  let upcase = string.uppercase(name)
  case list.contains(names, upcase) {
    True -> Ok(MonthName(upcase))
    False -> Error("`" <> name <> "`" <> " is not a valid month name")
  }
}

/// get int of `Month`
///
pub fn to_int(d: Month) -> Int {
  case d {
    MonthNumber(v) -> v
    MonthName(v) -> {
      let assert Ok(#(_, i)) =
        list.index_map(names, fn(name, i) { #(name, i + 1) })
        |> list.find(fn(it) { it.0 == v })
      i
    }
  }
}

/// get name of `Month`
///
pub fn to_name(d: Month) -> String {
  case d {
    MonthNumber(v) -> {
      let assert Ok(dd) = list.at(names, v - 1)
      dd
    }
    MonthName(v) -> v
  }
}

/// `Month` to string
///
/// ```gleam
/// let month = from_int(1) 
/// to_s(month) // "1"
/// ```
/// ```gleam
/// let month = from_str("JAN")
/// to_s(month) // "JAN"
/// ```
pub fn to_s(d: Month) -> String {
  case d {
    MonthNumber(value) -> int.to_string(value)
    MonthName(value) -> value
  }
}

/// compare two `Month`
///
pub fn compare(a: Month, b: Month) -> Order {
  int.compare(to_int(a), to_int(b))
}

/// get next `Month`
///
pub fn next(a: Month) -> Option(Month) {
  case from_int(to_int(a) + 1) {
    Ok(v) -> Some(v)
    Error(_) -> None
  }
}
