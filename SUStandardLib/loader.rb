#-------------------------------------------------------------------------------
#
#    Author: Julia Christina Eneroth (eneroth3@gmail.com)
# Copyright: Copyright (c) 2017
#   License: MIT
#
#-------------------------------------------------------------------------------
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
