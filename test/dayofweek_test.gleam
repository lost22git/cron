import gleeunit
import gleeunit/should
import gleam/option.{None, Some}
import field/dayofweek.{All, Any, Every, Index, Last, Or, Range, Uni}
import util/weekday.{WeekdayName, WeekdayNumber}
import field/types.{
  EveryAll, EveryRange, EveryUni, OrEvery, OrRange, OrUni, RangeVal,
}

pub fn main() {
  gleeunit.main()
}

pub fn to_s_test() {
  Any
  |> dayofweek.to_s()
  |> should.equal("?")

  All
  |> dayofweek.to_s()
  |> should.equal("*")

  let a = WeekdayName("MON")
  let b = WeekdayName("WED")
  let c = WeekdayNumber(2)
  let d = WeekdayNumber(4)

  let rab = RangeVal(a, b)
  let rcd = RangeVal(c, d)

  Uni(a)
  |> dayofweek.to_s()
  |> should.equal("MON")

  Uni(c)
  |> dayofweek.to_s()
  |> should.equal("2")

  Range(rab)
  |> dayofweek.to_s()
  |> should.equal("MON-WED")

  Range(rcd)
  |> dayofweek.to_s()
  |> should.equal("2-4")

  Every(EveryAll(2))
  |> dayofweek.to_s()
  |> should.equal("*/2")

  Every(EveryUni(a, 2))
  |> dayofweek.to_s()
  |> should.equal("MON/2")

  Every(EveryUni(c, 2))
  |> dayofweek.to_s()
  |> should.equal("2/2")

  Every(EveryRange(rab, 2))
  |> dayofweek.to_s()
  |> should.equal("MON-WED/2")

  Every(EveryRange(rcd, 2))
  |> dayofweek.to_s()
  |> should.equal("2-4/2")

  Or([OrUni(a), OrRange(rab), OrEvery(EveryRange(rab, 2))])
  |> dayofweek.to_s()
  |> should.equal("MON,MON-WED,MON-WED/2")

  Or([OrUni(c), OrRange(rcd), OrEvery(EveryUni(c, 2))])
  |> dayofweek.to_s()
  |> should.equal("2,2-4,2/2")

  Index(3, a)
  |> dayofweek.to_s()
  |> should.equal("MON#3")

  Index(3, c)
  |> dayofweek.to_s()
  |> should.equal("2#3")

  Last(Some(a))
  |> dayofweek.to_s()
  |> should.equal("MONL")

  Last(Some(c))
  |> dayofweek.to_s()
  |> should.equal("2L")

  Last(None)
  |> dayofweek.to_s()
  |> should.equal("L")
}
