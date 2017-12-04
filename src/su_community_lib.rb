# Library containing methods commonly used along with the SketchUp Ruby API.
#
# For simplicity's sake the library doesn't refine the API's existing modules
# and classes but defines its own corresponding modules.
module SUCommunityLib

  # Ensure character encoding is correct for users with non-English names.
  current_path = __FILE__.dup
  if current_path.respond_to?(:force_encoding)
    current_path.force_encoding("UTF-8")
  end

  # Path to library's directory.
  LIB_DIR = File.join(File.dirname(current_path), File.basename(current_path, ".*"))

  Dir.glob(File.join(LIB_DIR, "**/*.rb")).each { |p| require p }

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
    Dir.glob(File.join(LIB_DIR, "**/*.rb")).each { |p| load(p) }
    $VERBOSE = verbose

    # Use zero timer hack to save calling command to console stack even though
    # it clears the console. Otherwise the user wont be able to use Up Arrow
    # to call the same command again.
    ::UI.start_timer(0) { SKETCHUP_CONSOLE.clear } if clear_console

    Sketchup.undo if undo

    nil
  end

end
