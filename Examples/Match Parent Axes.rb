module SUCommunityLib
module Example

# Make selected instances' axes match those of the active drawing context.
# Useful to get texture positioning to match between drawing contexts.
module AlignAxes

  def self.make_all_unique(instances)
    instances.each(&:make_unique)
  end

  def self.line_up_axes
    model = Sketchup.active_model
    model.start_operation("Line Up Axes", true)
    instances = model.selection.select { |i| SUCommunityLib::LEntity.instance?(i) }

    # Different instances of the same definition needs to be made unique to have
    # their axes adjusted individually.

    # Groups are silently made unique.
    make_all_unique(instances.grep(Sketchup::Group))

    # The user is asked whether components too should be made unique as this may
    # not be their intention.
    msg =
      "There are multiple instances of the same component in the "\
      "selection. To line up the axes of all of them they must be made unique.\n\n"\
      "Do you want to continue?"
    definitions = instances.map(&:definition).uniq
    unless instances.size == definitions.size || UI.messagebox(msg, MB_YESNO) == IDYES
      model.abort_operation
      return
    end
    make_all_unique(instances.grep(Sketchup::ComponentInstance))

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
      SUCommunityLib::LComponentDefinition.place_axes(
        instance.definition,
        instance.transformation.inverse * model.edit_transform
      )
    end

    model.commit_operation
  end

  UI.menu("Plugins").add_item("Line Up Axes") { line_up_axes }

end
end
end
