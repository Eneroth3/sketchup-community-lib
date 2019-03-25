require 'testup/testcase'
require_relative '../../tools/loader'

class TC_SKP < TestUp::TestCase

  SKP = SkippyLib::SKP

  def setup
    # ...
  end

  def teardown
    # ...
  end

  #-----------------------------------------------------------------------------

  def generate_temp_path(extension = nil)
    t = Time.now.strftime("%Y%m%d")
    filename = "#{t}-#{$PID}-#{rand(0x100000000).to_s(36)}"
    filename << extension if extension

    File.join(Dir.tmpdir, filename)
  end

  def support_dir
    basename = File.basename(__FILE__, ".*")
    path = File.dirname(__FILE__)

    File.join(path, basename)
  end

  def test_guid
    model = Sketchup.active_model
    model.start_operation("Test Version")
    path = generate_temp_path(".skp")

    definition = model.definitions.add("Test component")
    # Add content to avoid purging.
    definition.entities.add_cpoint(ORIGIN)
    definition.save_as(path)

    assert_equal(SKP.guid(path), definition.guid, "File GUID should match component GUID.")

    File.delete(path)
    model.abort_operation
  end

  def test_version
    model = Sketchup.active_model
    model.start_operation("Test Version")
    path = generate_temp_path(".skp")

    definition = model.definitions.add("Test component")
    # Add content to avoid purging.
    definition.entities.add_cpoint(ORIGIN)
    definition.save_as(path)

    assert_equal(SKP.version(path), Sketchup.version, "File should be made in running SU version.")

    File.delete(path)
    model.abort_operation
  end

  def test_valid_Query
    assert(SKP.valid?(support_dir + "/6.skp"), "File is a SketchUp model.")
    refute(SKP.valid?(support_dir + "/Not a model.txt"), "File is not a SketchUp model.")
  end

end
