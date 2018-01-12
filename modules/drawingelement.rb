module SkippyLib

# Namespace for methods related to SketchUp's native Drawingelement class.
module LDrawingelement

  # List all InstancePaths pointing towards this Entity throughout the model.
  #
  # If the entity is a ComponentDefinition, the paths leading to its instances
  # will be listed.
  #
  # @param entity [Sketchup::Drawingelement]
  #
  # @example
  #   # Select an Entity:
  #   SkippyLib::LDrawingelement.all_instance_paths(Sketchup.active_model.selection.first)
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
