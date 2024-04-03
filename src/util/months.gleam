import gleam/int
import gleam/list
import gleam/string

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

/// get `#(min, max)` of `Month`
///
pub fn int_range() -> #(Int, Int) {
  #(1, list.length(names))
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
pub fn from_int(value: Int) -> Result(Month, Nil) {
  let #(min, max) = int_range()
  case min <= value, value <= max {
    True, True -> Ok(MonthNumber(value))
    _, _ -> Error(Nil)
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
pub fn from_name(str: String) -> Result(Month, Nil) {
  let upcase = string.uppercase(str)
  case list.contains(names, upcase) {
    True -> Ok(MonthName(upcase))
    False -> Error(Nil)
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
