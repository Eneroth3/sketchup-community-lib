require 'testup/testcase'

class TC_LEdge < TestUp::TestCase

  LEdge = SkippyLib::LEdge

  def setup
    open_new_model
  end

  def teardown
    discard_model_changes
  end

  #-----------------------------------------------------------------------------

  def test_midpoint
    pts = [Geom::Point3d.new(0, 0, 0), Geom::Point3d.new(2, 2, 2)]
    edge = Sketchup.active_model.active_entities.add_edges(pts).first
    midpoint = LEdge.midpoint(edge)
    expectation = Geom::Point3d.new(1, 1, 1)
    edge.erase!

    assert_equal(expectation, midpoint)
  end

end
