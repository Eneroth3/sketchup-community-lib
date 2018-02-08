module SkippyLib

# Namespace for methods related to SketchUp's native Entities collection class.
module LEntities

  # Copy entities, similar to how native Entities#transform_entities moves them.
  #
  # @param entities [Sketchup::Entities]
  # @param transformation [Geom::Transformation]
  # @param ent_a [Array<Sketchup::Drawingelement>]
  #
  # @raise [ArgumentError] if all entity objects aren't in the Entities collection.
  # @raise [ArgumentError] if Entities isn't the active drawing context
  #   (this is due to a SketchUp API limitation).
  #
  # @return [Array<Drawingelement>]
  def self.copy_entities(entities, transformation, ent_a)
    unless (ent_a - entities.to_a).empty?
      raise ArgumentError, "All Entity objects must belong to Entities collection."
    end
    unless entities == entities.model.active_entities
      raise ArgumentError, "Can only copy entities in the active drawing context."
    end

    temp_group = entities.add_group(ent_a)
    ary = entities.add_instance(
      temp_group.definition,
      transformation * temp_group.transformation
    ).explode
    temp_group.explode

    # We don't want EdgeUse and other obscure, non-drawingelement, objects returned.
    ary.grep(Sketchup::Drawingelement)
  end

end
end
