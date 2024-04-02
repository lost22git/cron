import gleeunit
import gleeunit/should
import field/year.{All, Any, Every, Or, Range, Uni}
import field/types.{
  EveryAll, EveryRange, EveryUni, OrEvery, OrRange, OrUni, RangeVal,
}

pub fn main() {
  gleeunit.main()
}

pub fn to_s_test() {
  All
  |> year.to_s()
  |> should.equal("*")

  Any
  |> year.to_s()
  |> should.equal("?")

  Uni(2010)
  |> year.to_s()
  |> should.equal("2010")

  Range(RangeVal(2010, 2020))
  |> year.to_s()
  |> should.equal("2010-2020")

  Every(EveryAll(2))
  |> year.to_s()
  |> should.equal("*/2")

  Every(EveryUni(2010, 2))
  |> year.to_s()
  |> should.equal("2010/2")

  Every(EveryRange(RangeVal(2010, 2020), 2))
  |> year.to_s()
  |> should.equal("2010-2020/2")

  Or([
    OrUni(2010),
    OrRange(RangeVal(2010, 2020)),
    OrEvery(EveryRange(RangeVal(2010, 2020), 2)),
  ])
  |> year.to_s()
  |> should.equal("2010,2010-2020,2010-2020/2")
}
