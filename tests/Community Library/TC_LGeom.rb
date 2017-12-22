require 'testup/testcase'

class TC_LGeom < TestUp::TestCase

  LGeom = SUCommunityLib::LGeom

  def setup
    #...
  end

  def teardown
    #...
  end

  #-----------------------------------------------------------------------------

  def test_polygon_area
    pts = [
      Geom::Point3d.new(0, 10, 0),
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(10, 0, 0),
      Geom::Point3d.new(10, 10, 0)
    ]
    area = LGeom.polygon_area(pts)
    expecetd_area = 100

    assert_equal(area, expecetd_area)

    pts = [
      Geom::Point3d.new(0, 10, 0),
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(10, 0, 0),
      Geom::Point3d.new(10, 10, 0),
      Geom::Point3d.new(5, 5, 0)
    ]
    area = LGeom.polygon_area(pts)
    expecetd_area = 75

    assert_equal(expecetd_area, area)
  end

  def test_polygon_normal
    pts = [
      Geom::Point3d.new(0, 10, 0),
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(10, 0, 0),
      Geom::Point3d.new(10, 10, 0),
      Geom::Point3d.new(5, 5, 0)
    ]
    normal = LGeom.polygon_normal(pts)
    expected_normal = Z_AXIS

    assert_equal(expected_normal, normal)
  end

end
