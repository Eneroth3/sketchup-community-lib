Sketchup.require "modules/component_definition"
Sketchup.require "modules/entity"

module SkippyLib

# Make nested components unique.
module DeepMakeUnique

  # Make all definitions within scope unique to that scope.
  #
  # @param scope [
  #   Sketchup::Group,
  #   Sketchup::ComponentInstance,
  #   Sketchup::ComponentDefinition,
  #   Array<
  #     Sketchup::Group,
  #     Sketchup::ComponentInstance,
  #     Sketchup::ComponentDefinition
  #    >
  #  ]
  #
  # @return [Void].
  def self.deep_make_unique(scope)
    scope = [scope] unless scope.is_a?(Array)

    # Instance within the scope that already use a shared definition should keep
    # using a shared definition. Once one instance is made unique its new
    # definition is remembered and re-used for the others.
    replacement_table = {}

    instances = scope.flat_map { |e| LEntity.instance?(e) ? e : e.instances }
    instances.each { |i| recursive_make_unique(i, scope, replacement_table) }

    nil
  end

  # Recursively traverses instance and child instances and make them unique to
  # the defined scope.
  #
  # @param instance [Sketchup::Group, Sketchup::ComponentInstance]
  # @param scope [Array<Sketchup::Group, Sketchup::ComponentInstance>]
  # @param replacement_table [Hash]
  #
  # @return [Void]
  def self.recursive_make_unique(instance, scope, replacement_table)
    definition = LEntity.definition(instance)

    if replacement_table[definition]
      LEntity.swap_definition(instance, replacement_table[definition])
      return
    end

    # A new unique definition is only created if the definition has instances
    # outside of the scope. If the definition is already unique to the scope
    # this instance doesn't need to be made unique.
    unless LComponentDefinition.unique_to?(definition, scope)
      instance.make_unique
      old_definition = definition
      definition = LEntity.definition(instance)
      replacement_table[old_definition] = definition
    end

    definition.entities.each do |i|
      next unless LEntity.instance?(i)
      recursive_make_unique(i, scope, replacement_table)
    end

    nil
  end
  private_class_method :recursive_make_unique

end
end
