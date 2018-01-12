module SkippyLib

# Namespace for methods related to SketchUp's native UI module.
module LUI

  # Add menu item at custom position in menu.
  #
  # The custom position is only used in SketchUp for Windows version 2016 and
  # above. In other versions the menu item will be placed at the end of the
  # menu. Please note that this is an undocumented SketchUp API behavior that
  # may be subject to change.
  #
  # @param menu [UI::Menu]
  # @param name [String]
  # @param position [Fixnum, nil]
  #
  # @example
  #   # Add Menu Item Right Below Entity Info
  #   UI.add_context_menu_handler do |menu|
  #     SkippyLib::LUI.add_menu_item(menu, "Entity Color Info", 1) do
  #       model = Sketchup.active_model
  #       entity = model.selection.first
  #       return unless entity
  #       color = entity.material ? entity.material.color : model.rendering_options["ForegroundColor"]
  #       UI.messagebox(color.to_a.join(", "))
  #     end
  #   end
  #
  # @return [Fixnum] identifier of menu item.
  def self.add_menu_item(menu, name, position = nil, &block)
    if position && Sketchup.platform == :platform_win && Sketchup.version.to_i >= 16
      menu.add_item(name, position, &block)
    else
      menu.add_item(name, &block)
    end
  end

  # Get platform dependent icon file extension, e.g. for mouse cursor or toolbar.
  #
  # For SU versions below 2016 ".png" is returned. For newer versions ".svg" is
  # returned on Windows and ".pdf" on Mac.
  #
  # @example
  #   # Create Toolbar with Crips Vector Icon If Supported
  #   # Assume the files my_icon.png, my_icon.svg and my_icon.pdf all exists.
  #   basename = "my_icon"
  #   filename = basename + SkippyLib::LUI.icon_file_extension
  #   tb = UI::Toolbar.new("My Toolbar")
  #   cmd = UI::Command.new("Do Stuff") { UI.messagebox("Stuff is done.") }
  #   cmd.large_icon = cmd.small_icon = filename
  #   cmd.tooltip = "Do Stuff"
  #   cmd.status_bar_text = "Perform stuff to do when stuff needs to be done and such."
  #   tb.add_item(cmd)
  #   tb.show unless tb.get_last_state == TB_HIDDEN
  #
  # @return [String]
  def self.icon_file_extension
    if Sketchup.version.to_i < 16
      ".png"
    elsif Sketchup.platform == :platform_win
      ".svg"
    else
      ".pdf"
    end
  end

  # Open directory and, if file is specified, select it.
  #
  # Commonly referred to in UIs as "Open File Location",
  # "Reveal in Finder/Explorer", "Show Containing Folder" and "Show in Folder".
  #
  # @param path [String] Path to directory or file to reveal.
  #
  # @example
  #   # Reveal file containing source code for this method.
  #   path = SkippyLib::LUI.method(:reveal_path).source_location.first
  #   SkippyLib::LUI.reveal_path(path)
  #
  #   # Open directory containing source code for this method (without selecting
  #   # the file).
  #   path = SkippyLib::LUI.method(:reveal_path).source_location.first
  #   dir_path = File.dirname(path)
  #   SkippyLib::LUI.reveal_path(dir_path)
  #
  #
  # @return [Void]
  def self.reveal_path(path)
    raise(ArgumentError, "No such file.") unless File.exist?(path)

    win = Sketchup.platform == :platform_win
    dir = File.directory?(path)
    path = path.tr("/", "\\").encode("ISO-8859-1") if win

    command = win ? "explorer.exe " : "open "
    command << (win ? "/select," : "-R ") unless dir
    command << "\"#{path}\""
    system(command)

    nil
  end

end
end
