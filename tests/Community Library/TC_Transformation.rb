require 'testup/testcase'

class TC_Transformation < TestUp::TestCase

  LTransformation = SUCommunityLib::LGeom::LTransformation

  # Copied from TestUp2 tests for SketchUp Ruby API.
  DivideByZeroTol = 1.0e-10

  # Transformation that is scaled, sheared and rotated in all sorts of weird ways.
  # Created by generated random values between 0.5 and 1.5.
  TrArbitrary = Geom::Transformation.new([
    0.6659020798475525, 0.7563298801682948, 1.2304333867430537, 0,
    0.5255701896498736, 1.2000850097458482, 0.5551255073894125, 0.9411061283451855,
    0.9055675476053245, 1.2593342527824833, 1.0736847987057314, 0.5048702169825546,
    0.8815187812185686, 1.1875845990707674, 0.6093097598311678, 0.5700086077795378
  ])

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def test_create_from_axes
    origin_in = Geom::Point3d.new(34, 23.23, 23)
    x_axis_in = Geom::Vector3d.new(234.45, 34.456, -43.456)
    y_axis_in = Geom::Vector3d.new(567.3, -45, -456.546)
    z_axis_in = Geom::Vector3d.new(234.4, 345, -435)
    tr = LTransformation.create_from_axes(origin_in, x_axis_in, y_axis_in, z_axis_in)
    x_axis_out = Geom::Vector3d.new(tr.to_a.values_at(0..2))
    y_axis_out = Geom::Vector3d.new(tr.to_a.values_at(4..6))
    z_axis_out = Geom::Vector3d.new(tr.to_a.values_at(8..10))
    origin_out = Geom::Point3d.new(tr.to_a.values_at(12..14))
    assert_equal(origin_out, origin_in)
    assert_equal(x_axis_out, x_axis_in)
    assert_equal(y_axis_out, y_axis_in)
    assert_equal(z_axis_out, z_axis_in)
  end

  def test_create_euler_angles
    x_in = -14.degrees
    y_in = 7.degrees
    z_in = 45.degrees

    # This is the order rotations should be applied in.
    tr_reference = Geom::Transformation.rotation(ORIGIN, Z_AXIS, z_in) *
      Geom::Transformation.rotation(ORIGIN, Y_AXIS, y_in) *
      Geom::Transformation.rotation(ORIGIN, X_AXIS, x_in)

    tr = LTransformation.create_from_euler_angles(ORIGIN, x_in, y_in, z_in)

    assert_equal(tr_reference.to_a, tr.to_a)
  end

  def test_determinant
    tr = Geom::Transformation.new([434, 2343, 123])
    determinant = LTransformation.determinant(tr)
    msg = "Determinant should not include translation."
    assert_in_delta(1.0, determinant, DivideByZeroTol, msg)
  end

  def test_euler_angles
    x_in = -14
    y_in = 7
    z_in = 45

    # This is the order rotations should be applied in.
    tr = Geom::Transformation.rotation(ORIGIN, Z_AXIS, z_in.degrees) *
      Geom::Transformation.rotation(ORIGIN, Y_AXIS, y_in.degrees) *
      Geom::Transformation.rotation(ORIGIN, X_AXIS, x_in.degrees)

    x_out, y_out, z_out = LTransformation.euler_angles(tr).map(&:radians)

    assert_in_delta(x_in, x_out, DivideByZeroTol, "Wrong X angle")
    assert_in_delta(y_in, y_out, DivideByZeroTol, "Wrong Y angle")
    assert_in_delta(z_in, z_out, DivideByZeroTol, "Wrong Z angle")
  end

  def test_extract_shearing
    tr_out = LTransformation.extract_shearing(TrArbitrary)
    determinant = LTransformation.determinant(tr_out)
    msg = "Determinant should be 1.0 for transformation only resembling shearing."
    assert_in_delta(1.0, determinant, DivideByZeroTol, msg)
  end

  def test_flipped_Query
    tr = Geom::Transformation.scaling(-1, 1, 1)
    msg = "Flipping along 1 axis makes a flipped transformation"
    assert(LTransformation.flipped?(tr), msg)

    tr = Geom::Transformation.scaling(-1, -1, 1)
    msg = "Flipping along 2 axes does not make a flipped transformation"
    refute(LTransformation.flipped?(tr), msg)

    tr = Geom::Transformation.scaling(-1, -1, -1)
    msg = "Flipping along 3 axes makes a flipped transformation"
    assert(LTransformation.flipped?(tr), msg)
  end

  def test_identity_Query
    tr = TrArbitrary * TrArbitrary.inverse
    msg = "Transformation should be regarded as the identity transformation."
    assert(LTransformation.identity?(tr), msg)
  end

  def test_reset_scaling
    tr_in = TrArbitrary
    tr_out = LTransformation.reset_scaling(tr_in)

    determinant_out = LTransformation.determinant(tr_out)
    x_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(0..2))
    y_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(4..6))
    z_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(8..10))
    x_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(0..2))
    y_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(4..6))
    z_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(8..10))

    msg =
      "Reseting scaling of sheared transformation should not create a "\
      "transformation with determinant being 1, but a transformation where "\
      "all axes have the length 1."
    refute(determinant_out == 1, msg)

    assert(x_axis_out.length == 1, "X axis length should be 1.")
    assert(y_axis_out.length == 1, "Y axis length should be 1.")
    assert(z_axis_out.length == 1, "Z axis length should be 1.")
    assert(x_axis_out.parallel?(x_axis_in), "Reseting scale should keep X axis parallel.")
    assert(y_axis_out.samedirection?(y_axis_in), "Reseting scale should not change Y axis direction.")
    assert(z_axis_out.samedirection?(z_axis_in), "Reseting scale should not change Z axis direction.")

    tr_flipped = Geom::Transformation.scaling(-1, 1, 1)
    tr_unscaled_flipped = LTransformation.reset_scaling(tr_flipped)
    msg = "Reseting scaling should un-flip transformation."
    refute(LTransformation.flipped?(tr_unscaled_flipped), msg)
  end

  def test_reset_shearing
    tr_in = TrArbitrary
    tr_out = LTransformation.reset_shearing(tr_in, true)

    determinant_in = LTransformation.determinant(tr_in)
    determinant_out = LTransformation.determinant(tr_out)
    assert_equal(determinant_in.to_l, determinant_out.to_l)

    x_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(0..2))
    y_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(4..6))
    z_axis_in = Geom::Vector3d.new(tr_in.to_a.values_at(8..10))
    x_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(0..2))
    y_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(4..6))
    z_axis_out = Geom::Vector3d.new(tr_out.to_a.values_at(8..10))
    assert(x_axis_out.samedirection?(x_axis_in), "X axis should keep its direction.")
    assert(x_axis_out.perpendicular?(y_axis_out), "Axes should be perpendicular.")
    assert(x_axis_out.perpendicular?(z_axis_out), "Axes should be perpendicular.")
    assert(y_axis_out.perpendicular?(z_axis_out), "Axes should be perpendicular.")
  end

end
