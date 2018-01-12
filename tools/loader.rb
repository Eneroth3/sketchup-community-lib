module SkippyLib

# Load all modules, e.g. for testing.
module Loader

  # Ensure character encoding is correct for directories with non-English names.
  current_dir = __dir__
  if current_dir.respond_to?(:force_encoding)
    current_dir.force_encoding("UTF-8")
  end

  LIB_ROOT = File.expand_path("../", current_dir)
  $LOAD_PATH << LIB_ROOT
  LOAD_PATTERN = File.join(LIB_ROOT, "modules", "**/*.rb")

  # Load all .rb files in library.
  #
  # @return [Void]
  def self.require_all
    Dir.glob(LOAD_PATTERN).each { |p| require p }

    nil
  end

  require_all

  # Reload library.
  #
  # @param clear_console [Boolean] Whether console should be cleared.
  # @param undo [Boolean] Whether last oration should be undone.
  #
  # @return [Void]
  def self.reload(clear_console = true, undo = false)
    # Hide warnings for already defined constants.
    verbose = $VERBOSE
    $VERBOSE = nil
    Dir.glob(LOAD_PATTERN).each { |p| load(p) }
    $VERBOSE = verbose

    # Use zero timer hack to save calling command to console stack even though
    # it clears the console. Otherwise the user wont be able to use Up Arrow
    # to call the same command again.
    UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

    Sketchup.undo if undo

    nil
  end

end
end

