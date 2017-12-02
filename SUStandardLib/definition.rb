module SUStandardLib

# Namespace for methods related to SketchUp's native ComponentDefinition class.
module ComponentDefinition

  # Get definition used by given instance.
  # For Versions before SU 2015 there was no Group#definition method.
  #
  # @param [Sketchup::ComponentInstance, Sketchup::Group, Sketchup::Image]
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
  # @param [Sketchup::ComponentDefiniton]
  # @param [Geom::Transformation] axes
  #   A Transformation object defining the new axes placement relative to old
  #   axes.
  # @param [Boolean] adjust_instances
  #   Whether all instances should have their transformations updated to
  #   compensate for the change in component axes. If +true+ the geometry will
  #   stay in the same place (in model space), if +false+ the instances' axes
  #   will stay in the same place.
  #
  # @example Move component's axes to its its bottom front left corner
  #   # Select a component in the model and run:
  #   definition = Sketchup.active_model.selection.first.definition
  #   bottom_front_left_pt = definition.bounds.min
  #   new_axes = Geom::Transformation.new(bottom_front_left_pt)
  #   SUStandardLib::ComponentDefinition.place_axes(definition, new_axes)
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
