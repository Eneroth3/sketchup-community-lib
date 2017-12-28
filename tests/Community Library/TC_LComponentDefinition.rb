require 'testup/testcase'

class TC_LComponentDefinition < TestUp::TestCase

  LComponentDefinition = SUCommunityLib::LComponentDefinition

  def group_definiton(group)
    # Group#definition only available in SU2015 and later.
    group.model.definitions.find { |d| d.instances.include?(group) }
  end

  def setup
    model = Sketchup.active_model

    @containers = {}

    @containers[:"1"]     = model.entities.add_group
    @containers[:"1.1"]   = @containers[:"1"].entities.add_group
    @containers[:"1.1.1"] = @containers[:"1.1"].entities.add_group
    @containers[:"1.2"]   = @containers[:"1"].entities.add_group
    @containers[:"2"]     = model.entities.add_instance(
      group_definiton(@containers[:"1"]),
      IDENTITY
    )
    @containers[:"3"]     = model.entities.add_instance(
      group_definiton(@containers[:"1.1.1"]),
      IDENTITY
    )

    # Prevent garbage collection.
    # Note that using Group#entities directly causes the group to be made unique.
    # A reference to the group's definition's entities must be used!
    @containers.each_value { |c| group_definiton(c).entities.add_cpoint(ORIGIN) }

    @entity = group_definiton(@containers[:"1.1.1"]).entities.add_cpoint(ORIGIN)

    @component_not_in_model = model.definitions.add("My Component Definition")
    @entity_not_in_model = @component_not_in_model.entities.add_cpoint(ORIGIN)
  end

  def teardown
    @containers.each_value { |c| c.erase! if c.valid? }
  end

  #-----------------------------------------------------------------------------

  def test_unique_to_Query
    msg = "Entity is unique to container."
    assert(LComponentDefinition.unique_to?(@entity, group_definiton(@containers[:"1.1.1"])), msg)

    msg = "Entity is not unique to container. There are other instances of this container."
    refute(LComponentDefinition.unique_to?(@entity, @containers[:"1.1.1"]), msg)

    msg = "Entity is not unique to container."
    refute(LComponentDefinition.unique_to?(@entity, @containers[:"1"]), msg)

    msg = "Entity is unique to containers."
    assert(LComponentDefinition.unique_to?(@entity, [@containers[:"1"], @containers[:"2"], @containers[:"3"]]), msg)

    msg = "Entity is not unique to containers."
    refute(LComponentDefinition.unique_to?(@entity, [@containers[:"1"], @containers[:"2"]]), msg)

    if Sketchup.version.to_i >= 17
      instance_paths = [
        Sketchup::InstancePath.new([@containers[:"1"]]),
        Sketchup::InstancePath.new([@containers[:"2"]])
      ]
      msg = "Entity is unique to instance paths."
      assert(LComponentDefinition.unique_to?(@containers[:"1.2"], instance_paths), msg)

      instance_path = Sketchup::InstancePath.new([@containers[:"1"]])
      msg = "Entity is not within instance path."
      refute(LComponentDefinition.unique_to?(@containers[:"2"], instance_path), msg)

      instance_path = Sketchup::InstancePath.new([@containers[:"1"]])
      msg = "Entity is not unique to instance path."
      refute(LComponentDefinition.unique_to?(@containers[:"1.1.1"], instance_path), msg)
    end
  end

end
