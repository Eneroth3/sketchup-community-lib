require 'testup/testcase'
require_relative '../../tools/loader'

class TC_LPoint3d < TestUp::TestCase

  LPoint3d = SkippyLib::LGeom::LPoint3d

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def test_between_Query
    pt_start = ORIGIN
    pt_end = Geom::Point3d.new(1, 0, 0)
    pt_between = Geom::Point3d.new(0.5, 0, 0)
    pt_outside = Geom::Point3d.new(1.1, 0, 0)

    assert(LPoint3d.between?(pt_between, pt_start, pt_end))
    refute(LPoint3d.between?(pt_outside, pt_start, pt_end))
    assert(LPoint3d.between?(pt_start, pt_start, pt_end, true))
    refute(LPoint3d.between?(pt_start, pt_start, pt_end, false))
  end

  def test_front_of_plane_Query
    pt_front = Geom::Point3d.new(1, 0, 0)
    pt_back = Geom::Point3d.new(-1, 0, 0)
    plane_geom = [ORIGIN, X_AXIS]
    plane_ary = [1.0, -0.0, -0.0, -0.0]

    assert(LPoint3d.front_of_plane?(pt_front, plane_geom))
    refute(LPoint3d.front_of_plane?(pt_back, plane_geom))
    assert(LPoint3d.front_of_plane?(pt_front, plane_ary))
    refute(LPoint3d.front_of_plane?(pt_back, plane_ary))
  end

end
