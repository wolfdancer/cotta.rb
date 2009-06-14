=begin
if RUBY_PLATFORM =~ /mswin|mingw/
  begin
    require 'win32/open3'
  rescue LoadError
    warn "You must 'gem install win32-open3' to use Cotta on Windows"
    exit 1
  end
else
  require 'open3'
end
=end

module Cotta
  
# Command runner
class CommandRunner
  attr_reader :outputs

  def initialize(command)
    @command = command
  end
  
  # executs the command.  If a closure is
  # given, it will be called with the io to the process
  # If not, it will print out the log pre-fixed with a random number for the process,
  # collects the output and return the output when the process finishes.
  # This method will also raise CommandError if the process fails.
  def execute
    id = rand(10000)
    puts "[#{id}]$> #{@command}"
    output = nil
    IO.popen(@command) do |io|
      if (block_given?)
        output = yield io
      else
        output = load_output(id, io)
      end
    end
    last_process = $?
    raise CommandError.new(last_process, output), @command unless last_process.exitstatus == 0
    return output
  end
  
  private
  def load_output(id, io)
    output = ''
    while (line = io.gets) do
      puts "[#{id}] #{line}"
      output << line
    end
    return output
  end
end
end
