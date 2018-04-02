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

end
