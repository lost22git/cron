import gleeunit
import gleeunit/should
import gleam/option.{None, Some}
import field/dayofweek.{
  All, Any, Every, Index, Last, Or, OrEvery, OrIndex, OrLast, OrRange, OrUni,
  Range, Uni,
}
import util/weekday
import field/common.{EveryAll, EveryRange, EveryUni, RangeVal}

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

  let assert Ok(a) = weekday.from_name("MON")
  let assert Ok(b) = weekday.from_name("WED")
  let assert Ok(c) = weekday.from_int(2)
  let assert Ok(d) = weekday.from_int(4)

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

  Or([
    OrUni(a),
    OrRange(rab),
    OrEvery(EveryRange(rab, 2)),
    OrIndex(1, a),
    OrLast(Some(a)),
  ])
  |> dayofweek.to_s()
  |> should.equal("MON,MON-WED,MON-WED/2,MON#1,MONL")

  Or([
    OrUni(c),
    OrRange(rcd),
    OrEvery(EveryUni(c, 2)),
    OrIndex(1, c),
    OrLast(Some(c)),
  ])
  |> dayofweek.to_s()
  |> should.equal("2,2-4,2/2,2#1,2L")
}
