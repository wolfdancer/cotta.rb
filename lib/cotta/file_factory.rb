module Cotta
# The file factory of Cotta files that handles creation of the CottaFile and CottaDir
# instances.  This class also can be used to start command lines
  class FileFactory
    attr_accessor :command_interface

    def initialize(system=PhysicalSystem.new)
      @system = system
      @command_interface = CommandInterface.new
    end

=begin not for 1.0 release
    # Invoke the command line through the backing system
    def shell(command_line, &block)
      @system.shell(command_line, &block)
    end
=end
    def pwd
      dir(@system.pwd)
    end

=begin not for 1.0 release
    # Starts the process.  Unlike shell method, this method does not
    # collect the output, thus suitable for starting a server in Ruby
    # and leave it running for a long time
    def start(command_line)
      @system.shell(command_line) do |io|
        if (block_given?)
          yield io
        else
          while (line = io.gets)
            puts line
          end
        end
      end
    end

    def command_interface=(value)
      if (value)
        @command_interface = value
      else
        @command_interface = CommandInterface.new
      end
    end
=end

    # Returns a CottaDir instance with the given path
    def dir(path)
      return nil unless path
      return CottaDir.new(@system, Pathname.new(path))
    end

    # Returns the FileFactory instance that represents the
    # physical file system
    def self::physical
      PHYSICAL
    end

    # Return the FileFactory instance that represents an
    # in-memory file system
    def self::in_memory
      FileFactory.new(InMemorySystem.new)
    end

    # Returns a CottDirectory with the PhysicalSystem
    def self::dir(path)
      return nil unless path
      return FileFactory.new.dir(File.expand_path(path))
    end

    # Returns a CottaFile in the current system with the path
    def file(path)
      return nil unless path
      return CottaFile.new(@system, Pathname.new(path))
    end

    # Returns a CottaFile with the PhysicalSystem and the given path
    def self::file(path)
      return nil unless path
      return FileFactory.physical.file(File.expand_path(path))
    end

    # Returns a CottaDir with the PhysicalSystem and is the parent of the given file path
    def self::parent_dir(path)
      return FileFactory.file(path).parent
    end

    # Creates the entry given a path.  This will return either
    # CottaFile or CottaDirectory depending by checking the path
    # passed in, which means that if neither a directory nor a file
    # exists with this name it will raise an error
    def entry(path)
      entry_instance = file(path)
      unless (entry_instance.exists?)
        entry_instance = dir(path)
        raise "#{path} exists as niether file nor directory" unless entry_instance.exists?
      end
      return entry_instance
    end

=begin not for release 1.0
    def environment!(variable)
      @system.environment!(variable)
    end

    def environment(variable, default = '')
      @system.environment(variable, default)
    end
=end

  end
  PHYSICAL = FileFactory.new(PhysicalSystem.new)
end