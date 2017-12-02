# Library containing methods commonly used along with the SketchUp Ruby API.
#
# For simplicity's sake the library doesn't refine the API's existing modules
# and classes but defines its own corresponding modules.
module SUStandardLib

  current_path = __FILE__.dup
  if current_path.respond_to?(:force_encoding)
    current_path.force_encoding("UTF-8")
  end
  Dir.glob(File.join(File.dirname(current_path), "*.rb")).each do |path|
    next if path == current_path
    require path
  end

end
