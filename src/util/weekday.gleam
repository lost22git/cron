import gleam/int
import gleam/string
import gleam/list

pub opaque type Weekday {
  WeekdayNumber(value: Int)
  WeekdayName(value: String)
}

/// names of `Weekday`
///
pub const names = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

/// get `#(min, max)` of `Weekday`
///
pub fn int_range() -> #(Int, Int) {
  #(1, list.length(names))
}

/// `Weekday` to string
///
/// ```gleam
/// let weekday = from_int(1) 
/// to_s(weekday) // "1"
/// ```
/// ```gleam
/// let weekday = from_str("SUN")
/// to_s(weekday) // "SUN"
/// ```
pub fn to_s(d: Weekday) -> String {
  case d {
    WeekdayNumber(value) -> int.to_string(value)
    WeekdayName(value) -> value
  }
}

/// create `Weekday` from a int value
/// 
/// | int | name |
/// |:---:|:----:|
/// | 1 | SUN |
/// | 2 | MON |
/// | 3 | TUE |
/// | 4 | WED |
/// | 5 | THU |
/// | 6 | FRI |
/// | 7 | SAT |
///
pub fn from_int(value: Int) -> Result(Weekday, Nil) {
  let #(min, max) = int_range()
  case min <= value, value <= max {
    True, True -> Ok(WeekdayNumber(value))
    _, _ -> Error(Nil)
  }
}

/// create `Weekday` from a string name
/// 
/// | int | name |
/// |:---:|:----:|
/// | 1 | SUN |
/// | 2 | MON |
/// | 3 | TUE |
/// | 4 | WED |
/// | 5 | THU |
/// | 6 | FRI |
/// | 7 | SAT |
///
pub fn from_name(str: String) -> Result(Weekday, Nil) {
  let upcase = string.uppercase(str)
  case list.contains(names, upcase) {
    True -> Ok(WeekdayName(upcase))
    False -> Error(Nil)
  }
}

/// get int of `Weekday`
///
pub fn to_int(d: Weekday) -> Int {
  case d {
    WeekdayNumber(v) -> v
    WeekdayName(v) -> {
      let assert Ok(#(_, i)) =
        list.index_map(names, fn(name, i) { #(name, i + 1) })
        |> list.find(fn(it) { it.0 == v })
      i
    }
  }
}

/// get name of `Weekday`
///
pub fn to_name(d: Weekday) -> String {
  case d {
    WeekdayNumber(v) -> {
      let assert Ok(dd) = list.at(names, v - 1)
      dd
    }
    WeekdayName(v) -> v
  }
}
