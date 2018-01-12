module SkippyLib

# Namespace for methods related to SketchUp's native Edge class.
module LEdge

  # Get the midpoint position for an edge.
  #
  # @param edge [Sketchup::Edge]
  #
  # @example
  #   entities = Sketchup.active_model.active_entities
  #   edges = entities.add_edges(ORIGIN, Geom::Point3d.new(1.m, 0, 0))
  #   edge = edges.first
  #   SkippyLib::LEdge.midpoint(edge)
  #
  # @return [Geom::Point3d]
  def self.midpoint(edge)
    Geom.linear_combination(
      0.5,
      edge.start.position,
      0.5,
      edge.end.position
    )
  end

end
end
