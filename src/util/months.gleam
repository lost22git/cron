import gleam/int

// pub type MonthName {
//   JAN
//   FEB
//   MAR
//   APR
//   MAY
//   JUN
//   JUL
//   AUG
//   SEP
//   OCT
//   NOV
//   DEC
// }

pub type Month {
  MonthNumber(value: Int)
  MonthName(value: String)
}

pub fn to_s(d: Month) -> String {
  case d {
    MonthNumber(value) -> int.to_string(value)
    MonthName(value) -> value
  }
}
