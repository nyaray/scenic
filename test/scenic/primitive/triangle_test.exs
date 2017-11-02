#
#  Created by Boyd Multerer on 5/8/17. Re-written on 11/02/17
#  Copyright © 2017 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Primitive.TriangleTest do
  use ExUnit.Case, async: true
  doctest Scenic

  alias Scenic.Primitive
  alias Scenic.Primitive.Triangle


  @data     {{20, 300}, {400, 300}, {400, 0}}


  #============================================================================
  # build / add

  test "build works" do
    p = Triangle.build( @data )
    assert Primitive.get_parent_uid(p) == -1
    assert Primitive.get_module(p) == Triangle
    assert Primitive.get(p) == @data
  end


  #============================================================================
  # verify

  test "verify passes valid data" do
    assert Triangle.verify( @data ) == true
  end

  test "verify fails invalid data" do
    assert Triangle.verify( {{20, 300}, {400, 300}, 400, 0} )         == false
    assert Triangle.verify( {{20, 300}, {400, 300}, {400, :banana}} ) == false
    assert Triangle.verify( :banana )                                 == false
  end

  #============================================================================
  # styles

  test "valid_styles works" do
    assert Triangle.valid_styles() == [:hidden, :color, :border_color, :border_width]
  end

  #============================================================================
  # transform helpers

  test "default_pin returns the center of the rect" do
    assert Triangle.default_pin(@data) == {273, 200}
  end

  test "centroid returns the centroid of the rect" do
    assert Triangle.centroid(@data) == {273, 200}
  end

  test "expand expands the data" do
    {{x0,y0},{x1,y1},{x2,y2}} = Triangle.expand(@data, 10)
    # rounding to avoid floating-point errors from messing up the tests
    assert {
      {round(x0), round(y0)},
      {round(x1), round(y1)},
      {round(x2), round(y2)}
    } ==   {{410, 310}, {410, -21}, {-9, 310}}
  end

  #============================================================================
  # point containment
  test "contains_point? returns true if it contains the point" do
    assert Triangle.contains_point?(@data, {273, 200})  == true
    assert Triangle.contains_point?(@data, {30, 299})   == true
    assert Triangle.contains_point?(@data, {399, 299})  == true
    assert Triangle.contains_point?(@data, {399, 10})   == true
  end

  test "contains_point? returns false if the point is outside" do
    # first, outside the triangle, but inside the bounding rect
    assert Triangle.contains_point?(@data, {30, 100})   == false
    # clearly outside
    assert Triangle.contains_point?(@data, {19, 200})   == false
    assert Triangle.contains_point?(@data, {401, 200})  == false
    assert Triangle.contains_point?(@data, {273, -1})   == false
    assert Triangle.contains_point?(@data, {273, 301})  == false
  end

  #============================================================================
  # serialization

  test "serialize native works" do
    native = <<
      20  :: integer-size(16)-native,
      300 :: integer-size(16)-native,
      400 :: integer-size(16)-native,
      300 :: integer-size(16)-native,
      400 :: integer-size(16)-native,
      0   :: integer-size(16)-native,
    >>
    assert Triangle.serialize(@data)           == {:ok, native}
    assert Triangle.serialize(@data, :native)  == {:ok, native}
  end

  test "serialize big works" do
    assert Triangle.serialize(@data, :big) == {:ok, <<
      20  :: integer-size(16)-big,
      300 :: integer-size(16)-big,
      400 :: integer-size(16)-big,
      300 :: integer-size(16)-big,
      400 :: integer-size(16)-big,
      0   :: integer-size(16)-big,
    >>}
  end

  test "deserialize native works" do
    bin = <<
      20  :: integer-size(16)-native,
      300 :: integer-size(16)-native,
      400 :: integer-size(16)-native,
      300 :: integer-size(16)-native,
      400 :: integer-size(16)-native,
      0   :: integer-size(16)-native,
    >>
    assert assert Triangle.deserialize(bin)          == {:ok, @data, ""}
    assert assert Triangle.deserialize(bin, :native) == {:ok, @data, ""}
  end

  test "deserialize big works" do
    bin = <<
      20  :: integer-size(16)-big,
      300 :: integer-size(16)-big,
      400 :: integer-size(16)-big,
      300 :: integer-size(16)-big,
      400 :: integer-size(16)-big,
      0   :: integer-size(16)-big,
    >>
    assert assert Triangle.deserialize(bin, :big) == {:ok, @data, ""}
  end

end
