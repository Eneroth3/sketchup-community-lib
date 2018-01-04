module SUCommunityLib

# Namespace for methods related to SketchUp's native ComponentDefinition class.
module LComponentDefinition

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

    LDrawingelement.all_instance_paths(definition).all? do |path|
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

  # Check if InstancePath (or Array representing InstancePath) starts with other
  # InstancePath (or Array representing InstancePath).
  #
  # @param path [Array, Sketchup::InstancePath]
  # @param beginning [Array, Sketchup::InstancePath]
  #
  # @return [Boolean]
  def self.instance_path_start_with_instance_path?(path, beginning)
    path.to_a.take(beginning.size) == beginning.to_a
  end
  private_class_method :instance_path_start_with_instance_path?

  # List definitions used by InstancePath/Array as well as the leaf entity.
  #
  # @param path [Array, Sketchup::InstancePath]
  #
  # @return [Array<Sketchup::Drawingelement>]
  def self.instance_path_definitions(path)
    path.map { |i| LEntity.instance?(i) ? LEntity.definition(i) : i }
  end
  private_class_method :instance_path_definitions

end
end
