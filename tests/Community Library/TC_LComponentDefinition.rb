require 'testup/testcase'

class TC_LComponentDefinition < TestUp::TestCase

  LComponentDefinition = SkippyLib::LComponentDefinition

  def setup
    basename = File.basename(__FILE__, ".*")
    path = File.dirname(__FILE__)
    test_model = File.join(path, basename, "Table.skp")
    disable_read_only_flag_for_test_models
    Sketchup.open_file(test_model)
    restore_read_only_flag_for_test_models

    definitions = Sketchup.active_model.definitions
    @stacy_def = definitions["Stacy"]
    @table_def = definitions["Table"]
    @table_def1 = definitions["Table#1"]
    @leg_def = definitions["leg"]
    @foot_def = definitions["foot"]
    @vase_def = definitions["vase"]
  end

  def teardown
    close_active_model
  end

  #-----------------------------------------------------------------------------

  def group_definiton(group)
    # Group#definition only available in SU2015 and later.
    group.model.definitions.find { |d| d.instances.include?(group) }
  end

  def test_place_axes
    model = Sketchup.active_model
    arbitrary_tr = Geom::Transformation.new([
      0.6659020798475525, 0.7563298801682948, 1.2304333867430537, 0,
      0.5255701896498736, 1.2000850097458482, 0.5551255073894125, 0,
      0.9055675476053245, 1.2593342527824833, 1.0736847987057314, 0,
      0.8815187812185686, 1.1875845990707674, 0.6093097598311678, 0.5700086077795378
    ])

    group = model.entities.add_group # Created with IDENTITY transformation.
    original_points = [
      Geom::Point3d.new(0, 0, 0),
      Geom::Point3d.new(1, 0, 0),
      Geom::Point3d.new(1, 1, 0),
      Geom::Point3d.new(0, 1, 0)
    ]
    face = group.entities.add_face(original_points)
    definition = group_definiton(group)

    LComponentDefinition.place_axes(definition, arbitrary_tr)
    modified_points = face.vertices.map(&:position)
    modified_points.each { |p| p.transform!(group.transformation)}
    msg =
      "Coordinates in model space within an instance should stay the same when "\
      "changing the definition axes (and no third argument says otherwise)."
    assert(modified_points == original_points, msg)

    group = model.entities.add_group
    group.entities.add_cpoint(ORIGIN)
    definition = group_definiton(group)

    LComponentDefinition.place_axes(definition, arbitrary_tr, false)
    msg =
      "Instances should keep their old transformation when third argument "\
      "is false."
    assert(group.transformation.to_a == IDENTITY.to_a, msg)

    close_active_model
  end

  def test_unique_to_Query_definitions
    definition = @stacy_def
    scope = @table_def
    msg = "Stacy is not unique Table because she isn't in Table."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = @table_def
    msg = "Leg isn't unique to Table because it also exists in table#1."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = [@table_def, @table_def1]
    msg = "Leg is unique to Table and table#1."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @vase_def
    scope = @table_def1
    msg = "Vase is not unique to Table#1 because it is also in the model root."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @foot_def
    scope = @leg_def
    msg = "Foot is unique to Leg."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)
  end

  def test_unique_to_Query_instances
    definition = @stacy_def
    scope = @table_def.instances
    msg = "Stacy is not unique Table because she isn't in Table."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @table_def
    scope = @table_def.instances
    msg = "Table is unique to its instances."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @table_def
    scope = @table_def.instances.first
    msg = "Table is unique to its first and only instance."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = @table_def.instances
    msg = "Leg isn't unique to Table because it also exists in table#1."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = @table_def.instances + @table_def1.instances
    msg = "Leg is unique to Table and table#1."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    # Invalid scope. Two Arrays of instances are passed instead of a single one.
    definition = @leg_def
    scope = [@table_def.instances, @table_def1.instances]
    assert_raises(ArgumentError) do
      LComponentDefinition.unique_to?(definition, scope)
    end

    definition = @vase_def
    scope = @table_def1.instances
    msg = "Vase is not unique to Table#1 because it is also in the model root."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @foot_def
    scope = @leg_def.instances
    msg = "Foot is unique to Leg."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @foot_def
    scope = @leg_def.instances.first
    msg = "Foot is not unique to a single instance of Leg."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = @leg_def.instances.first
    msg = "Leg is not unique to a single instance of Leg because there are other Leg instances."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @leg_def
    scope = @leg_def.instances
    msg = "Leg is unique to all instance of itself."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)
  end

  def test_unique_to_Query_paths
    skip("Implemented in SU2017") if Sketchup.version.to_i < 17

    definition = @stacy_def
    scope = Sketchup::InstancePath.new([])
    msg = "Stacy is unique to the model as a whole."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @stacy_def
    scope = Sketchup::InstancePath.new([@stacy_def.instances.first])
    msg = "Stacy is unique to her only instance."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @stacy_def
    scope = Sketchup::InstancePath.new([@table_def.instances.first])
    msg = "Stacy is not unique Table because she isn't in Table."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @foot_def
    scope = [
      Sketchup::InstancePath.new([@table_def.instances.first])
    ]
    msg = "Foot isn't unique to Table since it also exists Table#1."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @foot_def
    scope = [
      Sketchup::InstancePath.new([@table_def.instances.first]),
      Sketchup::InstancePath.new([@table_def1.instances.first])
    ]
    msg = "Foot is unique to Table and Table#1."
    assert(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @vase_def
    scope = [
      Sketchup::InstancePath.new([@table_def.instances.first])
    ]
    msg = "Vase isn't unique to Table since it also exists model root."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)

    definition = @vase_def
    scope = [
      Sketchup::InstancePath.new([@table_def.instances.first]),
      Sketchup::InstancePath.new([@vase_def.instances.find { |i| i.parent.is_a?(Sketchup::Model) }])
    ]
    msg = "Vase is unique to Table and Vase instance in the model root."
    refute(LComponentDefinition.unique_to?(definition, scope), msg)
  end

  def test_erase
    model = Sketchup.active_model
    definition = model.definitions.add("My Definition")
    definition.entities.add_cpoint(ORIGIN)
    model.entities.add_instance(definition, IDENTITY)
    old_count = model.definitions.size

    # Tested method must run inside an operator to work.
    model.start_operation("Erase Definition", true)
    LComponentDefinition.erase(definition)
    model.commit_operation

    count = model.definitions.size
    expected_count = old_count - 1
    assert_equal(expected_count, count)
  end

end
