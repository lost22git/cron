import gleeunit
import gleeunit/should
import gleam/option.{None, Some}
import field/dayofmonth.{All, Any, Every, Last, Or, Range, Uni}
import field/common.{
  EveryAll, EveryRange, EveryUni, OrEvery, OrRange, OrUni, RangeVal,
}

pub fn main() {
  gleeunit.main()
}

pub fn to_s_test() {
  All
  |> dayofmonth.to_s()
  |> should.equal("*")

  Any
  |> dayofmonth.to_s()
  |> should.equal("?")

  Uni(10)
  |> dayofmonth.to_s()
  |> should.equal("10")

  Range(RangeVal(10, 20))
  |> dayofmonth.to_s()
  |> should.equal("10-20")

  Every(EveryAll(2))
  |> dayofmonth.to_s()
  |> should.equal("*/2")

  Every(EveryUni(10, 2))
  |> dayofmonth.to_s()
  |> should.equal("10/2")

  Every(EveryRange(RangeVal(10, 20), 2))
  |> dayofmonth.to_s()
  |> should.equal("10-20/2")

  Or([
    OrUni(10),
    OrRange(RangeVal(10, 20)),
    OrEvery(EveryRange(RangeVal(10, 20), 2)),
  ])
  |> dayofmonth.to_s()
  |> should.equal("10,10-20,10-20/2")

  Last(Some(10))
  |> dayofmonth.to_s()
  |> should.equal("L-10")

  Last(None)
  |> dayofmonth.to_s()
  |> should.equal("L")
}
