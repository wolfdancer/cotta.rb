module Cotta
class CommandError < StandardError
  attr_reader :proc_status, :output

  def initialize(proc_status, output)
    @proc_status = proc_status
    @output = output
  end
end
end