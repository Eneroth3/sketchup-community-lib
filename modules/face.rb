module SkippyLib

# Namespace for methods related to SketchUp's native Face class.
module LFace

  # Get an array of all the interior loops of a face.
  #
  # If the face has no interior loops (holes in it) the array will be empty.
  #
  # @param face [SketchUp::Face]
  #
  # @example
  #   ents = Sketchup.active_model.active_entities
  #   outer_face = ents.add_face(
  #     Geom::Point3d.new(0,   0,   0),
  #     Geom::Point3d.new(0,   1.m, 0),
  #     Geom::Point3d.new(1.m, 1.m, 0),
  #     Geom::Point3d.new(1.m, 0,   0)
  #   )
  #   inner_face = ents.add_face(
  #     Geom::Point3d.new(0.25.m, 0.25.m, 0),
  #     Geom::Point3d.new(0.25.m, 0.75.m, 0),
  #     Geom::Point3d.new(0.75.m, 0.75.m, 0),
  #     Geom::Point3d.new(0.75.m, 0.25.m, 0)
  #   )
  #   SkippyLib::LFace.inner_loops(outer_face)
  #
  # @return [Array<Sketchup::Loop>]
  def self.inner_loops(face)
    face.loops - [face.outer_loop]
  end

  # Find the exterior face that a face forms a hole within, or nil if face isn't
  # inside another face.
  #
  # @param face [SketchUp::Face]
  #
  # @example
  #   ents = Sketchup.active_model.active_entities
  #   ents.add_face(
  #     Geom::Point3d.new(0,   0,   0),
  #     Geom::Point3d.new(0,   1.m, 0),
  #     Geom::Point3d.new(1.m, 1.m, 0),
  #     Geom::Point3d.new(1.m, 0,   0)
  #   )
  #   inner_face = ents.add_face(
  #     Geom::Point3d.new(0.25.m, 0.25.m, 0),
  #     Geom::Point3d.new(0.25.m, 0.75.m, 0),
  #     Geom::Point3d.new(0.75.m, 0.75.m, 0),
  #     Geom::Point3d.new(0.75.m, 0.25.m, 0)
  #   )
  #   outer_face = SkippyLib::LFace.wrapping_face(inner_face)
  #
  # @return [Sketchup::Face, nil]
  def self.wrapping_face(face)
    (face.edges.map(&:faces).inject(:&) - [face]).first
  end

end
end
