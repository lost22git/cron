import gleeunit
import gleeunit/should
import field/month.{All, Any, Every, Or, Range, Uni}
import field/common.{
  EveryAll, EveryRange, EveryUni, OrEvery, OrRange, OrUni, RangeVal,
}
import util/months

pub fn main() {
  gleeunit.main()
}

pub fn to_s_test() {
  All
  |> month.to_s()
  |> should.equal("*")

  Any
  |> month.to_s()
  |> should.equal("?")

  let assert Ok(a) = months.from_name("JAN")
  let assert Ok(b) = months.from_name("MAR")

  let assert Ok(c) = months.from_int(1)
  let assert Ok(d) = months.from_int(3)

  let rab = RangeVal(a, b)
  let rcd = RangeVal(c, d)

  Uni(a)
  |> month.to_s()
  |> should.equal("JAN")

  Uni(c)
  |> month.to_s()
  |> should.equal("1")

  Range(rab)
  |> month.to_s()
  |> should.equal("JAN-MAR")

  Range(rcd)
  |> month.to_s()
  |> should.equal("1-3")

  Every(EveryAll(2))
  |> month.to_s()
  |> should.equal("*/2")

  Every(EveryUni(a, 2))
  |> month.to_s()
  |> should.equal("JAN/2")

  Every(EveryUni(c, 2))
  |> month.to_s()
  |> should.equal("1/2")

  Every(EveryRange(rab, 2))
  |> month.to_s()
  |> should.equal("JAN-MAR/2")

  Every(EveryRange(rcd, 2))
  |> month.to_s()
  |> should.equal("1-3/2")

  Or([OrUni(a), OrRange(rab), OrEvery(EveryRange(rab, 2))])
  |> month.to_s()
  |> should.equal("JAN,JAN-MAR,JAN-MAR/2")

  Or([OrUni(c), OrRange(rcd), OrEvery(EveryUni(c, 2))])
  |> month.to_s()
  |> should.equal("1,1-3,1/2")
}
