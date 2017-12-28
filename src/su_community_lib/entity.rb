module SUCommunityLib

# Namespace for methods related to SketchUp's native Entity classes.
module LEntity

  # List all InstancePaths pointing towards this Entity throughout the model.
  #
  # If the entity is a ComponentDefinition, the paths leading to its instances
  # will be listed.
  #
  # @param entity [Sketchup::Drawingelement]
  #
  # @example
  #   # Select an Entity:
  #   SUCommunityLib::LEntity.all_instance_paths(Sketchup.active_model.selection.first)
  #
  # @return [Array<Array>, Array<Sketchup::InstancePath>]
  #   In SketchUp 2017+ InstancePath objects are returned. In earlier versions
  #   the corresponding Arrays are returned.
  def self.all_instance_paths(entity)
    unless entity.is_a?(Sketchup::Drawingelement)
      raise TypeError, "wrong argument type. Expected Sketchup::Drawingelement. #{entity.class} was supplied."
    end

    paths =
      if entity.is_a?(Sketchup::ComponentDefinition)
        entity.instances.flat_map { |i| recursive_instance_path_listing(i) }
      else
        recursive_instance_path_listing(entity)
      end

    return paths if Sketchup.version.to_i < 17

    paths.map { |a| Sketchup::InstancePath.new(a) }
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

  def self.recursive_instance_path_listing(entity, current_path = [], all_paths = [])
    current_path.unshift(entity)
    if entity.parent.is_a?(Sketchup::Model)
      all_paths << current_path
    else
      entity.parent.instances.each do |instance|
        recursive_instance_path_listing(instance, current_path.dup, all_paths)
      end
    end

    all_paths
  end
  private_class_method :recursive_instance_path_listing

end
end
