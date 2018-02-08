module SkippyLib
module Examples

# Make selected instances unique, similarly to the native feature, but affects
# child instances too.
#
# This example shows a number of SkippyLib features, including custom
# menu item position (next to native Make Unique), swapping group definitions
# and testing if a definition is unique to a certain scope.
#
# For this example SkippyLib is assumed to already be loaded in the top
# level namsepsace. For a real extension the library should be copied into the
# extension's own folder, wrapped under its namespace and loaded from there.
module DeepMakeUnique

  ACTION_NAME = "Deep Make Unique".freeze

  def self.deep_make_unique
    model = Sketchup.active_model

    scope = model.selection.select { |i| SkippyLib::LEntity.instance?(i) }
    return if scope.empty?

    old_definition_count = model.definitions.size

    model.start_operation(ACTION_NAME, true)
    SkippyLib::DeepMakeUnique.deep_make_unique(scope)
    model.commit_operation

    new_definitions_count = model.definitions.size - old_definition_count
    puts "#{new_definitions_count} new definitions created."

    nil
  end

  def self.menu_available?
    selection = Sketchup.active_model.selection

    selection.any? { |i| SkippyLib::LEntity.instance?(i) }
  end

  def self.menu_index
    selection = Sketchup.active_model.selection

    # Custom meny entry should succeed following entries:
    # - Entity Info
    # - Erase
    # - Hide
    # - Lock
    index = 4
    if selection.size == 1
      if selection.first.is_a?(Sketchup::ComponentInstance)
        # - --Separator--
        # - Edit Component
        # - Make Unique
        index += 3
      elsif selection.first.is_a?(Sketchup::Group)
        # - Edit Group
        index += 1
      end
    else
      # - --Separator--
      # - Explode
      # - Select
      # - Area
      # - Make Component
      # - Make Group
      index += 6
      if selection.grep(Sketchup::ComponentInstance).any?
        # - Make Unique
        index += 1
      end
    end

    index
  end

  @loaded ||= false
  unless @loaded
    @loaded = true

    UI.add_context_menu_handler do |menu|
      next unless menu_available?
      SkippyLib::LUI.add_menu_item(menu, ACTION_NAME, menu_index) do
        deep_make_unique
      end
    end
  end

end
end
end
