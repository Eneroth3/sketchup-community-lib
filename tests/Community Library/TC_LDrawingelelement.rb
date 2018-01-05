require 'testup/testcase'

class TC_LDrawingelelement < TestUp::TestCase

  LDrawingelement = SUCommunityLib::LDrawingelement

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

  def same_content(ary1, ary2)
    ((ary1 - ary2) & (ary2 - ary1)).empty?
  end

  def expected_path_class
    Sketchup.version.to_i >= 17 ? Sketchup::InstancePath : Array
  end

  def test_all_instance_paths_definition
    entity = @stacy_def
    paths = LDrawingelement.all_instance_paths(entity)
    expected_paths = [
      [@stacy_def.instances.first]
    ]
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    paths = paths.map(&:to_a)
    msg = "Stacy only exists in model root."
    assert(same_content(expected_paths, paths), msg)

    entity = @vase_def
    paths = LDrawingelement.all_instance_paths(entity)
    expected_paths = [
      [@table_def1.instances.first, @vase_def.instances.find { |i| i.parent == @table_def1 }],
      [@vase_def.instances.find { |i| i.parent.is_a?(Sketchup::Model) }]
    ]
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    paths = paths.map(&:to_a)
    msg = "Vase exists both in root and in Table#1."
    assert(same_content(expected_paths, paths), msg)

    entity = @leg_def
    paths = LDrawingelement.all_instance_paths(entity)
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    assert_equal(8, paths.size)

    entity = @foot_def
    paths = LDrawingelement.all_instance_paths(entity)
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    assert_equal(8, paths.size)
  end

  def test_all_instance_paths_instance
    entity = @stacy_def.instances.first
    paths = LDrawingelement.all_instance_paths(entity)
    expected_paths = [
      [entity]
    ]
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    paths = paths.map(&:to_a)
    msg = "Stacy only exists in model root."
    assert(same_content(expected_paths, paths), msg)

    entity = @vase_def.instances.find { |i| i.parent.is_a?(Sketchup::Model) }
    paths = LDrawingelement.all_instance_paths(entity)
    expected_paths = [
      [entity]
    ]
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    paths = paths.map(&:to_a)
    msg = "This vase instance only exists in the model root."
    assert(same_content(expected_paths, paths), msg)

    entity = @vase_def.instances.find { |i| i.parent == @table_def1 }
    paths = LDrawingelement.all_instance_paths(entity)
    expected_paths = [
      [@table_def1.instances.first, entity]
    ]
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    paths = paths.map(&:to_a)
    msg = "This vase instance only exists in Table#1."
    assert(same_content(expected_paths, paths), msg)

    entity = @leg_def.instances.first
    paths = LDrawingelement.all_instance_paths(entity)
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    # With only one instance of each table, any instance of a leg has just one path to it.
    assert_equal(1, paths.size)

    entity = @foot_def.instances.first
    paths = LDrawingelement.all_instance_paths(entity)
    assert_kind_of(Array, paths)
    assert_kind_of(expected_path_class, paths.first)
    # With 8 instances of the leg there are 8 paths to the one and only foot instance.
    assert_equal(8, paths.size)
  end

end
