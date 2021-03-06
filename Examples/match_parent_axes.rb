module SkippyLib
module Examples

# Make selected instances' axes match those of the active drawing context.
# Useful to get texture positioning to match between drawing contexts.
#
# This example shows how `LComponentDefinition.place_axes` can be used.
#
# For this example SkippyLib is assumed to already be loaded in the top
# level namsepsace. For a real extension the library should be copied into the
# extension's own folder, wrapped under its namespace and loaded from there.
module AlignAxes

  def self.make_unique(instances)
    # Groups are silently made unique.
    instances.grep(Sketchup::Group, &:make_unique)

    # The user is asked whether components too should be made unique as this may
    # not be their intention.
    msg =
      "There are multiple instances of the same component in the "\
      "selection. To line up the axes of all of them they must be made unique.\n\n"\
      "Do you want to continue?"
    definitions = instances.map { |i| SkippyLib::LEntity.definition(i) }.uniq
    unless instances.size == definitions.size || UI.messagebox(msg, MB_YESNO) == IDYES
      return false
    end
    instances.grep(Sketchup::ComponentInstance, &:make_unique)

    true
  end

  def self.line_up_axes
    model = Sketchup.active_model
    instances = model.selection.select { |i| SkippyLib::LEntity.instance?(i) }
    model.start_operation("Line Up Axes", true)

    # Different instances of the same definition needs to be made unique to have
    # their axes adjusted individually (assuming there aren't perfectly
    # overlapping instances).
    unless make_unique(instances)
      model.abort_operation
      return
    end

    # In theory passing the inverse of an instance's transformation to place_axes
    # should line up its axes to those of the parent drawing context.
    #
    # However, when this parent drawing context is the active drawing context
    # SketchUp uses to the global coordinate space rather than the local one,
    # meaning we have to actively take the so called "edit transformation" into
    # account.
    #
    # It is assumed all the selected instances are in the active drawing context.
    instances.each do |instance|
      SkippyLib::LComponentDefinition.place_axes(
        SkippyLib::LEntity.definition(instance),
        instance.transformation.inverse * model.edit_transform
      )
    end

    model.commit_operation
  end

  @loaded ||= false
  unless @loaded
    @loaded = true
    UI.menu("Plugins").add_item("Line Up Axes") { line_up_axes }
  end

end
end
end
