import gleam/int

// pub type WeekdayName {
//   MON
//   TUE
//   WED
//   THU
//   FRI
//   SAT
//   SUN
// }

pub type Weekday {
  WeekdayNumber(value: Int)
  WeekdayName(value: String)
}

pub fn to_s(d: Weekday) -> String {
  case d {
    WeekdayNumber(value) -> int.to_string(value)
    WeekdayName(value) -> value
  }
}
