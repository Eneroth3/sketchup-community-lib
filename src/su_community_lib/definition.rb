module SUCommunityLib

# Namespace for methods related to SketchUp's native ComponentDefinition class.
module LComponentDefinition

  # Get definition used by given instance.
  # For Versions before SU 2015 there was no Group#definition method.
  #
  # @param instance [Sketchup::ComponentInstance, Sketchup::Group, Sketchup::Image]
  #
  # @return [Sketchup::ComponentDefinition]
  def self.from_instance(instance)
    if instance.is_a?(Sketchup::ComponentInstance)
      instance.definition
    else
      instance.model.definitions.find { |d| d.instances.include?(instance) }
    end
  end

  # Define new axes placement for component.
  #
  # @param definition [Sketchup::ComponentDefiniton]
  # @param new_axes [Geom::Transformation]
  #   A Transformation object defining the new axes placement relative to old
  #   axes.
  # @param adjust_instances [Boolean]
  #   Whether all instances should have their transformations updated to
  #   compensate for the change in component axes. If +true+ the geometry will
  #   stay in the same place (in model space), if +false+ the instances' axes
  #   will stay in the same place.
  #
  # @example
  #   # Move Axes to BoundongBox Bottom Center
  #   # Select a component in the model and run:
  #   definition = Sketchup.active_model.selection.first.definition
  #   bottom_front_left = definition.bounds.corner(0)
  #   bottom_back_right = definition.bounds.corner(3)
  #   bottom_center = Geom.linear_combination(0.5, bottom_front_left, 0.5, bottom_back_right)
  #   new_axes = Geom::Transformation.new(bottom_center)
  #   SUCommunityLib::ComponentDefinition.place_axes(definition, new_axes)
  #
  # @return [Void]
  def self.place_axes(definition, new_axes, adjust_instances = true)
    definition.entities.transform_entities(
      new_axes.inverse,
      definition.entities.to_a
    )

    if adjust_instances
      definition.instances.each do |instance|
        instance.transformation *= new_axes
      end
    end

    nil
  end

end
end
