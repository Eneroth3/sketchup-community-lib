require 'testup/testcase'
require_relative '../../tools/loader'

class TC_Entities < TestUp::TestCase

  LEntities = SkippyLib::LEntities

  def setup
    #...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def test_move_entities
    open_new_model

    model = Sketchup.active_model
    original_face = model.entities.add_face([
      ORIGIN,
      Geom::Point3d.new(10, 0, 0),
      Geom::Point3d.new(10, 10, 0),
      Geom::Point3d.new(0, 10, 0)
    ])

    transformation =
      Geom::Transformation.scaling(2, 1, 1) *
      Geom::Transformation.translation(Geom::Vector3d.new(50, 0, 0))

    new_ents = LEntities.copy_entities(model.entities, transformation, [original_face])
    new_face = new_ents.grep(Sketchup::Face).first

    assert_equal(5, new_ents.size) # 1 face + 4 edges.
    assert_equal(200, new_face.area)

    discard_model_changes
  end

end
