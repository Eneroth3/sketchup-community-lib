module ExampleExtensionModule::SUStandardLib::Entity

  # List all InstancePaths pointing towards this Entity throughout the model.
  #
  # @param [Sketchup::Drawingelement]
  # @return [Array<Array>, Array<Sketchup::InstancePath>]
  #   In SketchUp 2017+ InstancePath objects are returned. In earlier versions
  #   the corresponding Arrays are returned.
  def self.all_instance_paths(entity)
    unless entity.is_a?(Sketchup::Drawingelement)
      raise TypeError, "wrong argument type. Expected Sketchup::Drawingelement. #{entity.class} was supplied."
    end

    recursive = lambda do |entity, current_path = [], all_paths = []|
      current_path.unshift(entity)
      if entity.parent.is_a?(Sketchup::Model)
        all_paths << current_path
      else
        entity.parent.instances.each do |instance|
          recursive.call(instance, current_path.dup, all_paths)
        end
      end

      all_paths
    end

    ary = recursive.call(entity)

    if Sketchup.version.to_i < 17
      return ary
    else
      return ary.map { |a| Sketchup::InstancePath.new(a) }
    end
  end

end
