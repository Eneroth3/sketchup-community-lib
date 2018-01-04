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
    if instance.is_a?(Sketchup::ComponentInstance) ||
       (Sketchup.version.to_a >= 15 && instance.is_a?(Sketchup::Group))
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

  # Check if definition is solely used within certain scope, e.g. another
  # definition, an array of groups or an instance path.
  #
  # @param definition [Sketchup::ComponentDefinition]
  # @param scopes [Sketchup::ComponentDefinition,
  #                 Sketchup::ComponentInstance,
  #                 Sketchup::Group,
  #                 Sketchup::InstancePath,
  #                 Array<
  #                   Sketchup::ComponentDefinition,
  #                   Sketchup::ComponentInstance,
  #                   Sketchup::Group,
  #                   Sketchup::InstancePath
  #                 >]
  #
  # @example
  #   # Check if all instances of the first component definition in the model is
  #   # within the selection (including within selected containers).
  #   model = Sketchup.active_model
  #   definition = model.definitions.first
  #   SUCommunityLib::LComponentDefinition.unique_to?(definition, model.selection.to_a)
  #
  # @return [Boolean]
  def self.unique_to?(definition, scopes)
    raise ArgumentError, "Expected ComponentDefinition." unless definition.is_a?(Sketchup::ComponentDefinition)
    scopes = [scopes] unless scopes.is_a?(Array)
    raise ArgumentError, "Scope is empty." if scopes.empty?

    LEntity.all_instance_paths(definition).all? do |path|
      scopes.any? do |scope|
        case scope
        when Sketchup::ComponentDefinition
          instance_path_definitions(path).include?(scope)
        when Sketchup::ComponentInstance, Sketchup::Group
          path.include?(scope)
        when defined?(Sketchup::InstancePath) && Sketchup::InstancePath
          instance_path_start_with_instance_path?(path, scope)
        else
          raise ArgumentError, "Unexpected scope #{scope.class}."
        end
      end
    end
  end

  # @param path [Array, Sketchup::InstancePath]
  # @param start [Array, Sketchup::InstancePath]
  def self.instance_path_start_with_instance_path?(path, beginning)
    # If start is empty array the index in the second line of code would
    # become negative, resulting in a mismatch.
    return true if beginning.empty?

    # The == comparison does not honor the order of the elements.
    # However SketchUp will only allow one single order in an InstancePath as
    # anything else would require circular component nesting.
    path.to_a[0..(beginning.size - 1)] == beginning.to_a
  end
  private_class_method :instance_path_start_with_instance_path?

  # @param path [Array, Sketchup::InstancePath]
  def self.instance_path_definitions(path)
    path.to_a[0..-2].map { |i| LEntity.instance?(i) ? from_instance(i) : i }
  end
  private_class_method :instance_path_definitions

end
end
