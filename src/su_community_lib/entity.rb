module SUCommunityLib

# Namespace for methods related to SketchUp's native Entity classes.
module LEntity

  # Get definition used by instance.
  # For Versions before SU 2015 there was no Group#definition method.
  #
  # @param instance [Sketchup::ComponentInstance, Sketchup::Group, Sketchup::Image]
  #
  # @return [Sketchup::ComponentDefinition]
  def self.definition(instance)
    if instance.is_a?(Sketchup::ComponentInstance) ||
       (Sketchup.version.to_i >= 15 && instance.is_a?(Sketchup::Group))
      instance.definition
    else
      instance.model.definitions.find { |d| d.instances.include?(instance) }
    end
  end

  # Test if entity is either group or component instance.
  #
  # Since a group is a special type of component groups and component instances
  # can often be treated the same.
  #
  # @example
  #   # Show Information of the Selected Instance
  #   entity = Sketchup.active_model.selection.first
  #   if !entity
  #     puts "Selection is empty."
  #   elsif SUCommunityLib::LEntity.instance?(entity)
  #     puts "Instance's transformation is: #{entity.transformation}."
  #     puts "Instance's definition is: #{entity.definition}."
  #   else
  #     puts "Entity is not a group or component instance."
  #   end
  #
  # @param entity [Sketchup::Entity]
  #
  # @return [Boolean]
  def self.instance?(entity)
    entity.is_a?(Sketchup::Group) || entity.is_a?(Sketchup::ComponentInstance)
  end

end
end
