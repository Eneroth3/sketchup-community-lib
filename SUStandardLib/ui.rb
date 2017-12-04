module SUStandardLib

# Namespace for methods related to SketchUp's native UI module.
module UI

  # Open folder.
  #
  # @param path [String] Path to directory to show.
  #
  # @example
  #   # Show directory containing source code for method.
  #   # In a real life situation when you have a path to a specific file it is
  #   # likely better to use the show_in_folder method to also select the file
  #   # than removing the file name from the path and using the open_folder
  #   # method.
  #   path = File.dirname(SUStandardLib::UI.method(:show_in_folder).source_location.first)
  #   SUStandardLib::UI.open_folder(path)
  #
  # @return [Void]
  def self.open_folder(path)
    if Sketchup.platform == :platform_win
      system("explorer.exe \"#{path.tr("/", "\\").encode("ISO-8859-1")}\"")
    else
      system("open \"#{path}\"")
    end

    nil
  end

  # Open directory and select file.
  #
  # Commonly referred to as "Reveal in Finder/Explorer" and
  # "Show Containing Folder".
  #
  # @param path [String] Path to file to show.
  #
  # @example
  #   # Show file containing source code for method.
  #   path = SUStandardLib::UI.method(:show_in_folder).source_location.first
  #   SUStandardLib::UI.show_in_folder(path)
  #
  #
  # @return [Void]
  def self.show_in_folder(path)
    if Sketchup.platform == :platform_win
      system("explorer.exe /select,\"#{path.tr("/", "\\").encode("ISO-8859-1")}\"")
    else
      system("open -R \"#{path}\"")
    end

    nil
  end

end
end
