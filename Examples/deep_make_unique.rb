module SUCommunityLib
module Example

# Make selected instances unique, similarly to the native feature, but include
# child instances.
#
# This example shows a number of SUCommunityLib features, including custom
# menu item position (next to native make Unique), swapping group definitions
# and testing if a definition is unique to a certain scope.
module DeepMakeUnique

  ACTION_NAME = "Deep Make Unique".freeze
  DEBUG_MODE = false

  # Used for debugging. Draws an edge within a definition so its instances can
  # easily be visually distinguished.
  #
  # @param definition [Sketchup::ComponentDefiniton]
  #
  # @return [Nothing]
  def self.mark_definition(definition)
    definition.entities.add_line(ORIGIN, [0, 0, 100])
  end

  # Recursively traverses instance and child instances and make them unique to
  # the defined scope.
  #
  # @param instance [Sketchup::Group, Sketchup::ComponentInstance]
  # @param scope [Array<Sketchup::Group, Sketchup::ComponentInstance>]
  # @replacement_table [Hash]
  #
  # @return [Nothing]
  def self.recursive_make_unique(instance, scope, replacement_table)
    definition = SUCommunityLib::LEntity.definition(instance)

    if replacement_table[definition]
      SUCommunityLib::LEntity.swap_definition(instance, replacement_table[definition])
      return
    end

    # A new unique definition is only created if the definition has instances
    # outside of the scope. If the definition is already unique to the scope
    # this instance doesn't need to be made unique.
    unless SUCommunityLib::LComponentDefinition.unique_to?(definition, scope)
      instance.make_unique
      old_definition = definition
      definition = SUCommunityLib::LEntity.definition(instance)
      replacement_table[old_definition] = definition
    end

    definition.entities.each do |i|
      next unless SUCommunityLib::LEntity.instance?(i)
      recursive_make_unique(i, scope, replacement_table)
    end

    mark_definition(definition) if DEBUG_MODE

    nil
  end

  # Make all definitions within scope unique to that scope.
  #
  # @param scope [Array<Sketchup::Group, Sketchup::ComponentInstance>]
  #
  # @returns [Nothing].
  def self.deep_make_unique(scope)
    # Instance within the scope that already use a shared definition should keep
    # using a shared definition. Once one instance is made unique its new
    # definition is remembered and re-used for the others.
    replacement_table = {}

    scope.each { |i| recursive_make_unique(i, scope, replacement_table) }

    nil
  end

  # Wrapper for deep_make_unique. Starts model operation and make the current
  # selection deep unique.
  #
  # @returns [Nothing]
  def self.perform_deep_make_unique_operation
    model = Sketchup.active_model

    scope = model.selection.select { |i| SUCommunityLib::LEntity.instance?(i) }
    return if scope.empty?

    old_definition_count = model.definitions.size

    model.start_operation(ACTION_NAME, true)
    deep_make_unique(scope)
    model.commit_operation

    new_definitions_count = model.definitions.size - old_definition_count
    puts "#{new_definitions_count} new definitions created."

    nil
  end

  def self.menu_available?
    selection = Sketchup.active_model.selection

    selection.any? { |i| SUCommunityLib::LEntity.instance?(i) }
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
      SUCommunityLib::LUI.add_menu_item(menu, ACTION_NAME, menu_index) do
        perform_deep_make_unique_operation
      end
    end
  end

end
end
end
