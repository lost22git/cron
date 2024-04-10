import gleeunit
import gleeunit/should
import util/range
import gleam/int
import gleam/iterator
import gleam/option.{type Option, Some}

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

pub fn iterator_test() {
  range.close_close(1, 3)
  |> range.iterator(fn(a) { Some(int.add(a, 1)) }, int.compare)
  |> iterator.to_list()
  |> should.equal([1, 2, 3])

  range.close_open(1, 3)
  |> range.iterator(fn(a) { Some(int.add(a, 1)) }, int.compare)
  |> iterator.to_list()
  |> should.equal([1, 2])

  range.open_open(1, 3)
  |> range.iterator(fn(a) { Some(int.add(a, 1)) }, int.compare)
  |> iterator.to_list()
  |> should.equal([2])

  range.open_close(1, 3)
  |> range.iterator(fn(a) { Some(int.add(a, 1)) }, int.compare)
  |> iterator.to_list()
  |> should.equal([2, 3])
}
