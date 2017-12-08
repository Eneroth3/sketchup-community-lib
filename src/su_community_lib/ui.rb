module SUCommunityLib

# Namespace for methods related to SketchUp's native UI module.
module LUI

  # Open directory and select file if defined.
  #
  # Commonly referred to in UIs as "Open File Location",
  # "Reveal in Finder/Explorer", "Show Containing Folder" and "Show in Folder".
  #
  # @param path [String] Path to directory or file to reveal.
  #
  # @example
  #   # Reveal file containing source code for this method.
  #   path = SUCommunityLib::LUI.method(:reveal_path).source_location.first
  #   SUCommunityLib::LUI.reveal_path(path)
  #
  #   # Open directory containing source code for this method (without selecting
  #   # the file).
  #   path = SUCommunityLib::LUI.method(:reveal_path).source_location.first
  #   dir_path = File.dirname(path)
  #   SUCommunityLib::LUI.reveal_path(dir_path)
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
