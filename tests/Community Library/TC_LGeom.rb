require 'testup/testcase'
require_relative '../../tools/loader'

class TC_LGeom < TestUp::TestCase

  LGeom = SkippyLib::LGeom

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

  def test_remove_duplicates
    output = LGeom.remove_duplicates([
      Geom::Point3d.new(1, 2, 3),
      Geom::Point3d.new(1, 2, 3),
      Geom::Point3d.new(4, 3, 1),
      Geom::Point3d.new(1, 2, 3),
      Geom::Point3d.new(5, 5, 5),
      Geom::Point3d.new(4, 3, 1)
    ])
    expected = LGeom.remove_duplicates([
      Geom::Point3d.new(1, 2, 3),
      Geom::Point3d.new(4, 3, 1),
      Geom::Point3d.new(5, 5, 5)
    ])
    assert_equal(output, expected)

    output = LGeom.remove_duplicates([
      Geom::Vector3d.new(1, 2, 3),
      Geom::Vector3d.new(1, 2, 3),
      Geom::Vector3d.new(4, 3, 1),
      Geom::Vector3d.new(1, 2, 3),
      Geom::Vector3d.new(5, 5, 5),
      Geom::Vector3d.new(4, 3, 1)
    ])
    expected = LGeom.remove_duplicates([
      Geom::Vector3d.new(1, 2, 3),
      Geom::Vector3d.new(4, 3, 1),
      Geom::Vector3d.new(5, 5, 5)
    ])
    assert_equal(output, expected)
  end

end
