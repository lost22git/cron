import gleeunit
import gleeunit/should
import field/minute.{All, Any, Every, Or, Range, Uni}
import field/types.{
  EveryAll, EveryRange, EveryUni, OrEvery, OrRange, OrUni, RangeVal,
}

pub fn main() {
  gleeunit.main()
}

pub fn to_s_test() {
  All
  |> minute.to_s()
  |> should.equal("*")

  Any
  |> minute.to_s()
  |> should.equal("?")

  Uni(10)
  |> minute.to_s()
  |> should.equal("10")

  Range(RangeVal(10, 20))
  |> minute.to_s()
  |> should.equal("10-20")

  Every(EveryAll(2))
  |> minute.to_s()
  |> should.equal("*/2")

  Every(EveryUni(10, 2))
  |> minute.to_s()
  |> should.equal("10/2")

  Every(EveryRange(RangeVal(10, 20), 2))
  |> minute.to_s()
  |> should.equal("10-20/2")

  Or([
    OrUni(10),
    OrRange(RangeVal(10, 20)),
    OrEvery(EveryRange(RangeVal(10, 20), 2)),
  ])
  |> minute.to_s()
  |> should.equal("10,10-20,10-20/2")
}
