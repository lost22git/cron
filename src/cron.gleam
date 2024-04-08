import gleam/io
import field.{type FieldDef, type FieldVal}
import util/months.{type Month}
import util/weekday.{type Weekday}
import gleam/option.{type Option}

pub fn main() {
  io.println("")
}

pub type CronDef {
  CronDef(
    second: Option(FieldDef(Int)),
    minute: Option(FieldDef(Int)),
    hour: Option(FieldDef(Int)),
    day_of_month: Option(FieldDef(Int)),
    month: Option(FieldDef(Month)),
    day_of_week: Option(FieldDef(Weekday)),
    yaer: Option(FieldDef(Int)),
  )
}

pub type Cron {
  Cron(
    cron_def: CronDef,
    second: Option(FieldVal(Int)),
    minute: Option(FieldVal(Int)),
    hour: Option(FieldVal(Int)),
    day_of_month: Option(FieldVal(Int)),
    month: Option(FieldVal(Month)),
    day_of_week: Option(FieldVal(Weekday)),
    yaer: Option(FieldVal(Int)),
  )
}

pub fn to_s(_cron: Cron) -> String {
  ""
}

pub fn validate(cron: Cron) -> Result(Cron, List(String)) {
  Ok(cron)
}
