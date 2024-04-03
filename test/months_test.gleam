import gleeunit
import gleeunit/should
import util/months

pub fn main() {
  gleeunit.main()
}

pub fn from_int_test() {
  let assert Ok(_) = months.from_int(1)
  let assert Ok(_) = months.from_int(12)

  let assert Error(_) = months.from_int(0)
  let assert Error(_) = months.from_int(13)
}

pub fn from_name_test() {
  let assert Ok(_) = months.from_name("jan")
  let assert Ok(_) = months.from_name("Jan")

  let assert Error(_) = months.from_name("anj")
}

pub fn to_s_test() {
  let assert Ok(d) = months.from_int(1)
  months.to_s(d)
  |> should.equal("1")

  let assert Ok(d) = months.from_name("Jan")
  months.to_s(d)
  |> should.equal("JAN")
}

pub fn to_int_test() {
  let assert Ok(d) = months.from_name("jan")
  months.to_int(d)
  |> should.equal(1)

  let assert Ok(d) = months.from_int(1)
  months.to_int(d)
  |> should.equal(1)
}

pub fn to_name_test() {
  let assert Ok(d) = months.from_name("jan")
  months.to_name(d)
  |> should.equal("JAN")

  let assert Ok(d) = months.from_int(1)
  months.to_name(d)
  |> should.equal("JAN")
}
