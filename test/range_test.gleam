import gleeunit
import gleeunit/should
import util/range
import gleam/int

pub fn main() {
  gleeunit.main()
}

pub fn include_test() {
  // close close
  {
    let r = range.close_close(1, 10)

    r
    |> range.include(1, int.compare)
    |> should.be_true

    r
    |> range.include(10, int.compare)
    |> should.be_true

    r
    |> range.include(0, int.compare)
    |> should.be_false

    r
    |> range.include(11, int.compare)
    |> should.be_false
  }
  // open open
  {
    let r = range.open_open(1, 10)

    r
    |> range.include(2, int.compare)
    |> should.be_true

    r
    |> range.include(9, int.compare)
    |> should.be_true

    r
    |> range.include(1, int.compare)
    |> should.be_false

    r
    |> range.include(10, int.compare)
    |> should.be_false
  }

  // close open
  {
    let r = range.close_open(1, 10)

    r
    |> range.include(1, int.compare)
    |> should.be_true

    r
    |> range.include(9, int.compare)
    |> should.be_true

    r
    |> range.include(0, int.compare)
    |> should.be_false

    r
    |> range.include(10, int.compare)
    |> should.be_false
  }

  // open close
  {
    let r = range.open_close(1, 10)

    r
    |> range.include(2, int.compare)
    |> should.be_true

    r
    |> range.include(10, int.compare)
    |> should.be_true

    r
    |> range.include(1, int.compare)
    |> should.be_false

    r
    |> range.include(11, int.compare)
    |> should.be_false
  }
}

pub fn to_s_test() {
  range.close_close(1, 10)
  |> range.to_s(int.to_string)
  |> should.equal("[1,10]")

  range.close_open(1, 10)
  |> range.to_s(int.to_string)
  |> should.equal("[1,10)")

  range.open_open(1, 10)
  |> range.to_s(int.to_string)
  |> should.equal("(1,10)")

  range.open_close(1, 10)
  |> range.to_s(int.to_string)
  |> should.equal("(1,10]")
}
