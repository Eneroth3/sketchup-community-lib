require 'testup/testcase'

class TC_LVector3d < TestUp::TestCase

  LVector3d = SUCommunityLib::LGeom::LVector3d

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def test_arbitrary_non_parallel_vector
    vector_in = Geom::Vector3d.new(1, 2, 3)
    vector_out = LVector3d.arbitrary_non_parallel_vector(vector_in)
    assert(vector_out.valid?)
    refute(vector_out.parallel?(vector_in))
  end

  def test_arbitrary_perpendicular_vector
    vector_in = Geom::Vector3d.new(1, 2, 3)
    vector_out = LVector3d.arbitrary_perpendicular_vector(vector_in)
    assert(vector_out.valid?)
    assert(vector_out.perpendicular?(vector_in))
  end

  def test_transform_as_normal
    tr = Geom::Transformation.new([
      1,   0,   0,  0,
      0.5, 1,   0,  0,
      0,   0,   1,  0,
      0,   0,   0,  1
    ])
    vector_in = Y_AXIS
    vector_out = LVector3d.transform_as_normal(vector_in, tr)
    assert_equal(1, vector_out.length)
    assert_equal(Y_AXIS, vector_out)
  end

end
