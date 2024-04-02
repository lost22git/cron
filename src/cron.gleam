import gleam/io
import field/second
import field/minute
import field/hour
import field/dayofmonth
import field/month
import field/dayofweek
import field/year
import field/types

pub fn main() {
  io.debug(types.RangeVal(from: 1, to: 10))
}

pub type Cron {
  Cron(
    second: second.FieldVal,
    minute: minute.FieldVal,
    hour: hour.FieldVal,
    day_of_month: dayofmonth.FieldVal,
    month: month.FieldVal,
    day_of_week: dayofweek.FieldVal,
    year: year.FieldVal,
  )
}
