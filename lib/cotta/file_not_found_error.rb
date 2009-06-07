module Cotta
class FileNotFoundError < StandardError
  attr_reader :pathname
  
  def initialize(pathname)
    @pathname = pathname
  end
  
  def message
    "file not found: #{pathname}"
  end
end
end