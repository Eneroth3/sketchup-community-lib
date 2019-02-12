require 'testup/testcase'
require_relative '../../tools/loader'

class TC_LFace < TestUp::TestCase

  LFace = SkippyLib::LFace

  def setup
    open_new_model

    @container = Sketchup.active_model.active_entities.add_group
    @outer_face = @container.entities.add_face(
      Geom::Point3d.new(0,   0,   0),
      Geom::Point3d.new(0,   1.m, 0),
      Geom::Point3d.new(1.m, 1.m, 0),
      Geom::Point3d.new(1.m, 0,   0)
    )
    @inner_face = @container.entities.add_face(
      Geom::Point3d.new(0.25.m, 0.25.m, 0),
      Geom::Point3d.new(0.25.m, 0.75.m, 0),
      Geom::Point3d.new(0.75.m, 0.75.m, 0),
      Geom::Point3d.new(0.75.m, 0.25.m, 0)
    )
    @outer_face.reverse! unless @outer_face.normal == Z_AXIS
    @inner_face.reverse! unless @inner_face.normal == Z_AXIS
  end

  def teardown
    discard_model_changes
  end

  #-----------------------------------------------------------------------------

  def test_wrapping_face
    # TODO: Test less trivial cases where the edges of inner face binds other
    # faces as well.
    outer_face = LFace.wrapping_face(@inner_face)

    assert(outer_face == @outer_face, "Wrong face returned.")
  end

  def test_inner_loops
    inner_loops = LFace.inner_loops(@outer_face)

    assert_kind_of(Array, inner_loops)
    assert_equal(1, inner_loops.size)
  end

  def test_arbitrary_interior_point
    point = LFace.arbitrary_interior_point(@outer_face)
    msg = "Returned point should be inside face, excluding boundaries."
    assert_equal(Sketchup::Face::PointInside, @outer_face.classify_point(point), msg)
  end

  def test_includes_point_Query
    msg = "Point is on boundary."
    assert(LFace.includes_point?(@outer_face, ORIGIN), msg)

    msg = "Point is on boundary."
    assert(LFace.includes_point?(@outer_face, ORIGIN, true), msg)

    msg = "Point is on face."
    assert(LFace.includes_point?(@outer_face, Geom::Point3d.new(0.1.m, 0.1.m, 0)), msg)

    msg = "Point is in hole."
    refute(LFace.includes_point?(@outer_face, Geom::Point3d.new(0.5.m, 0.5.m, 0)), msg)

    msg = "Point is on boundary."
    refute(LFace.includes_point?(@outer_face, ORIGIN, false), msg)
  end

  def test_triangulate
    triangles = LFace.triangulate(@outer_face)
    
    msg = "All elements are Arrays"
    assert(triangles.map(&:class).uniq == [Array], msg)
    
    msg = "All Arrays are 3 elements long"
    assert(triangles.map(&:size).uniq == [3], msg)
    
    msg = "All nested elements are points"
    assert(triangles.flatten.map(&:class).uniq == [Geom::Point3d], msg)
    
    msg = "Winding order should match that of face."
    assert(triangles.all? { |t| polygon_normal(t) == Z_AXIS }, msg)
  end
  
  private
  
  def polygon_normal(points)
    normal = Geom::Vector3d.new
    points.each_with_index do |pt0, i|
      pt1 = points[i + 1] || points.first
      normal.x += (pt0.y - pt1.y) * (pt0.z + pt1.z)
      normal.y += (pt0.z - pt1.z) * (pt0.x + pt1.x)
      normal.z += (pt0.x - pt1.x) * (pt0.y + pt1.y)
    end

    normal.normalize
  end

end
