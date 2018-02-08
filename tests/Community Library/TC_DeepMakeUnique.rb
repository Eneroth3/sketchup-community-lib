require 'testup/testcase'
require_relative '../../tools/loader'

class TC_DeepMakeUnique < TestUp::TestCase

  DeepMakeUnique = SkippyLib::DeepMakeUnique

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def open_test_model
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

  def test_deep_make_unique_Non_uniqie_no_childs
    open_test_model

    # Sketchup.active_model.definitions.size
    # # => 7

    DeepMakeUnique.deep_make_unique(@vase_def.instances.first)

    # Vase made unique.
    assert_equal(8, Sketchup.active_model.definitions.size)

    close_active_model
  end

  def test_deep_make_unique_Uniqie_no_childs
    open_test_model

    # Sketchup.active_model.definitions.size
    # # => 7

    DeepMakeUnique.deep_make_unique(@stacy_def.instances.first)

    # Stacy is already unique (good for her!)
    assert_equal(7, Sketchup.active_model.definitions.size)

    close_active_model
  end

  def test_deep_make_unique_Uniqie_with_non_unique_children
    open_test_model

    # Sketchup.active_model.definitions.size
    # # => 7

    DeepMakeUnique.deep_make_unique(@table_def.instances.first)

    # Board, leg and foot made unique.
    assert_equal(10, Sketchup.active_model.definitions.size)

    close_active_model
  end

end
