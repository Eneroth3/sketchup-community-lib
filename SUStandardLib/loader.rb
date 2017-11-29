#-------------------------------------------------------------------------------
#
#    Author: Julia Christina Eneroth (eneroth3@gmail.com)
# Copyright: Copyright (c) 2017
#   License: MIT
#
#-------------------------------------------------------------------------------
module SUStandardLib

  Dir.glob(File.join(File.dirname(__FILE__), "*.rb")).each do |path|
    next if path == __FILE__
    require path
  end

end
