require 'testup/testcase'

class TC_LPlane < TestUp::TestCase

  LPlane = SUCommunityLib::LGeom::LPlane

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def test_normal
    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal(Z_AXIS, ORIGIN)
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal("Hej, världen!")
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1, 1, 1, 1])
    end

    plane = [0.4569183360072988, 0.5396532536919619, -0.7071067811865478, -69.50778952585624]
    normal1 = LPlane.normal(plane)
    normal2 = Geom::Vector3d.new(0.4569183360072988, 0.5396532536919619, -0.7071067811865478)

    assert(normal1 == normal2, "normal1 and normal2 are not equivalent.")

    plane = [ORIGIN, X_AXIS]
    normal1 = LPlane.normal(plane)
    normal2 = X_AXIS

    assert(normal1 == normal2, "normal1 and normal2 are not equivalent.")
  end

  def test_point
    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point(Z_AXIS, ORIGIN)
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point("Hej, världen!")
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point([1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point([1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point([1, 1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.point([1, 1, 1, 1, 1])
    end

    plane = [0.4569183360072988, 0.5396532536919619, -0.7071067811865478, -69.50778952585624]
    point = LPlane.point(plane)

    assert(point.on_plane?(plane), "Point is not on plane.")

    plane = [ORIGIN, Y_AXIS]
    point = LPlane.point(plane)

    assert(point.on_plane?(plane), "Point is not on plane.")
  end

  def test_parallel_Query
    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal(Z_AXIS, ORIGIN)
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal("Hej, världen!")
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1, 1])
    end

    assert_raises(ArgumentError, "Invalid plane.") do
      LPlane.normal([1, 1, 1, 1, 1])
    end

    plane1 = [0.5, 0.6, -0.7, -69.0]
    plane2 = [0.5, 0.6, -0.7, 56.0]

    assert(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are plane parallel.")

    plane1 = [0.5, 0.6, -0.7, -69.0]
    plane2 = [-0.5, -0.6, 0.7, 56.0]

    assert(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are plane parallel.")

    plane1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(2, 4, 1)]
    plane2 = [Geom::Point3d.new(56, 4, 0), Geom::Vector3d.new(2, 4, 1)]

    assert(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are plane parallel.")

    plane1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(2, 4, 1)]
    plane2 = [Geom::Point3d.new(56, 4, 0), Geom::Vector3d.new(-2, -4, -1)]

    assert(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are plane parallel.")

    plane1 = [0.5, -0.6, -0.7, -69.0]
    plane2 = [-0.5, 0.6, -0.7, 56.0]

    refute(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are not plane parallel.")

    plane1 = [Geom::Point3d.new(0, 0, 0), Geom::Vector3d.new(2, 4, 1)]
    plane2 = [Geom::Point3d.new(56, 4, 0), Geom::Vector3d.new(-2, 4, 1)]

    refute(LPlane.parallel?(plane1, plane2), "plane1 and plane2 are not plane parallel.")
  end

  def test_same_Query
    plane1 = [0.0, 0.0, 1.0, 0.0]
    plane2 = [ORIGIN, Z_AXIS]

    assert(LPlane.same?(plane1, plane2), "plane1 and plane2 are the same.")

    plane1 = [ORIGIN, Y_AXIS]
    plane2 = [ORIGIN, Z_AXIS]

    refute(LPlane.same?(plane1, plane2), "plane1 and plane2 are not the same.")

    plane1 = [0.0, 0.0, 1.0, 0.0]
    plane2 = [ORIGIN, Z_AXIS.reverse]

    refute(LPlane.same?(plane1, plane2), "plane1 and plane2 are opposite.")
    assert(LPlane.same?(plane1, plane2, true), "plane1 and plane2 are the same.")
  end

end
