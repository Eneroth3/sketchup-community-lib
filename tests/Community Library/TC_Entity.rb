require 'testup/testcase'

class TC_LEntity < TestUp::TestCase

  LEntity = SUCommunityLib::LEntity

  def group_definiton(group)
    # Group#definition only available in SU2015 and later.
    group.model.definitions.find { |d| d.instances.include?(group) }
  end

  def setup
    model = Sketchup.active_model

    @containes = {}

    @containes[:"1"]     = model.entities.add_group
    @containes[:"1.1"]   = @containes[:"1"].entities.add_group
    @containes[:"1.1.1"] = @containes[:"1.1"].entities.add_group
    @containes[:"1.2"]   = @containes[:"1"].entities.add_group
    @containes[:"2"]     = model.entities.add_instance(
      group_definiton(@containes[:"1"]),
      IDENTITY
    )
    @containes[:"3"]     = model.entities.add_instance(
      group_definiton(@containes[:"1.1.1"]),
      IDENTITY
    )

    # Prevent garbage collection.
    # Note that using Group#entities directly causes the group to be made unique.
    # A reference to the group's definition's entities must be used!
    @containes.each_value { |c| group_definiton(c).entities.add_cpoint(ORIGIN) }

    @entity = group_definiton(@containes[:"1.1.1"]).entities.add_cpoint(ORIGIN)

    @component_not_in_model = model.definitions.add("My Component Definition")
    @entity_not_in_model = @component_not_in_model.entities.add_cpoint(ORIGIN)
  end

  def teardown
    @containes.each_value { |c| c.erase! if c.valid? }
  end

  #-----------------------------------------------------------------------------

  def test_all_instance_paths
    paths = LEntity.all_instance_paths(@entity)

    assert_kind_of(Array, paths)
    klass = Sketchup.version.to_i >= 17 ? Sketchup::InstancePath : Array
    assert_kind_of(klass, paths.first)
    paths = paths.map(&:to_a)
    assert_equal(
      paths,
      [
        [@containes[:"1"], @containes[:"1.1"], @containes[:"1.1.1"], @entity],
        [@containes[:"2"], @containes[:"1.1"], @containes[:"1.1.1"], @entity],
        [@containes[:"3"], @entity]
      ]
    )

    paths = LEntity.all_instance_paths(group_definiton(@containes[:"1.1.1"]))

    assert_kind_of(Array, paths)
    klass = Sketchup.version.to_i >= 17 ? Sketchup::InstancePath : Array
    assert_kind_of(klass, paths.first)
    paths = paths.map(&:to_a)
    assert_equal(
      paths,
      [
        [@containes[:"1"], @containes[:"1.1"], @containes[:"1.1.1"]],
        [@containes[:"2"], @containes[:"1.1"], @containes[:"1.1.1"]],
        [@containes[:"3"]]
      ]
    )

    paths = LEntity.all_instance_paths(@entity_not_in_model)
    assert_equal([], paths)
  end

end
