module SUStandardLib

# Namespace for methods related to SketchUp's native Entity classes.
module Entity

  # List all InstancePaths pointing towards this Entity throughout the model.
  #
  # @param entity [Sketchup::Drawingelement]
  #
  # @return [Array<Array>, Array<Sketchup::InstancePath>]
  #   In SketchUp 2017+ InstancePath objects are returned. In earlier versions
  #   the corresponding Arrays are returned.
  def self.all_instance_paths(entity)
    unless entity.is_a?(Sketchup::Drawingelement)
      raise TypeError, "wrong argument type. Expected Sketchup::Drawingelement. #{entity.class} was supplied."
    end

    # This code throws syntax error in SU 6 on Win. That is however not a
    # supported version.
    recursive = lambda do |e, current_path = [], all_paths = []|
      current_path.unshift(e)
      if e.parent.is_a?(Sketchup::Model)
        all_paths << current_path
      else
        e.parent.instances.each do |instance|
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
end
