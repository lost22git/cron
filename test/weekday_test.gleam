import gleeunit
import gleeunit/should
import util/weekday

pub fn main() {
  gleeunit.main()
}

pub fn from_int_test() {
  let assert Ok(_) = weekday.from_int(1)
  let assert Ok(_) = weekday.from_int(7)

  let assert Error(_) = weekday.from_int(0)
  let assert Error(_) = weekday.from_int(8)
}

pub fn from_name_test() {
  let assert Ok(_) = weekday.from_name("mon")
  let assert Ok(_) = weekday.from_name("Mon")

  let assert Error(_) = weekday.from_name("non")
}

pub fn to_s_test() {
  let assert Ok(d) = weekday.from_int(1)
  weekday.to_s(d)
  |> should.equal("1")

  let assert Ok(d) = weekday.from_name("sun")
  weekday.to_s(d)
  |> should.equal("SUN")
}

pub fn to_int_test() {
  let assert Ok(d) = weekday.from_name("sun")
  weekday.to_int(d)
  |> should.equal(1)

  let assert Ok(d) = weekday.from_int(1)
  weekday.to_int(d)
  |> should.equal(1)
}

pub fn to_name_test() {
  let assert Ok(d) = weekday.from_name("sun")
  weekday.to_name(d)
  |> should.equal("SUN")

  let assert Ok(d) = weekday.from_int(1)
  weekday.to_name(d)
  |> should.equal("SUN")
}
