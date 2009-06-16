require 'fileutils'

module Cotta
  # This class represents a file
  class CottaFile
    # factory with the backing system
    attr_reader :factory
    # path of this file
    attr_reader :path
    # stats of this file
    attr_reader :stat

    # creates an instance of file with the given factory and path
    def initialize(factory, path)
      @path = path
      @factory = factory
    end

    # name of this file
    def name
      return @path.basename.to_s
    end

    # extension of this file, with '.'
    def extname
      return @path.extname
    end

    # basename of this file
    def basename
      return @path.basename(extname).to_s
    end

    # stats of this file
    def stat
      factory.system.file_stat(@path)
    end

    # returns true if this file is older than the given file
    def older_than?(file)
      (stat <=> file.stat) == -1
    end

    # returns true if this file exists
    def exists?
      return factory.system.file_exists?(@path)
    end

    # returns the relative path from the given file or directory
    def relative_path_from(entry)
      path.relative_path_from(entry.path)
    end

    # returns the parent directory
    def parent
      return CottaDir.new(factory, @path.parent)
    end

    # copy this file to the target file
    def copy_to(target_file)
      target_file.parent.mkdirs
      factory.system.copy_file(path, target_file.path)
      target_file
    end

    # copy this file to the target path
    def copy_to_path(target_path)
      copy_to(cotta.file(target_path))
    end

    # move this file to the target file
    def move_to(target_file)
      target_file.parent.mkdirs
      factory.system.move_file(path, target_file.path)
    end

    # move this file to the target path
    def move_to_path(target_path)
      move_to(cotta.file(target_path))
    end

    # save conent to this file
    # this will create the parent directory if necessary
    def save(content = '')
      write {|file| file.printf content.to_s}
      self
    end

    # Calls open with 'w' argument and makes sure that the
    # parent directory of the file exists
    def write(&block)
      parent.mkdirs
      open('w', &block)
    end

    # Calls open with 'a' argument and make sure that the
    # parent directory of the file exists
    def append(&block)
      parent.mkdirs
      open('a', &block)
    end

    # Calls open with 'wb' argument, sets the io to binmode
    # and make sure that the parent directory of the file exists
    def write_binary(&block)
      parent.mkdirs
      if (block_given?)
        open('wb') do |io|
          io.binmode
          yield io
        end
      else
        io = open('wb')
        io.binmode
        io
      end
    end

=begin rdoc
    Loading the file full total.  This is used generally for loading
    an ascii file content.  It does not work with binary file on
    windows system because it does no put the system on binary mode
=end
    def load
      content = nil
      size = stat.size
      read do |io|
        content = io.read
      end
      return content
    end

    # calls open with 'r' as argument.
    def read(&block)
      open('r', &block)
    end

    # Calls open with 'r' as argument and sets the io to binary mode
    def read_binary
      if block_given?
        open('r') do |io|
          io.binmode
          yield io
        end
      else
        io = open('r')
        io.binmode
        io
      end
    end

    # reads the file and calls back for each line
    def foreach()
      open('r') do |file|
        file.each {|line| yield line}
      end
    end

    # opens the file with the g iven arguments
    def open(*args)
      result = f = factory.system.io(@path, *args)
      if block_given?
        begin
          result = yield f
        ensure
          f.close unless f.closed?
        end
      end
      result
    end

    # deletes the file
    def delete
      factory.system.delete_file(@path)
    end

    # reads this file as an archive and extracts the content
    # to the target directory.  If the target directory
    # is missing, it will create a directory in the same
    # directory as this file with the same basename
    def extract(directory = nil)
      require 'rubygems/package'
      directory = parent.dir(basename) unless directory
      read_binary do |io|
        reader = Gem::Package::TarReader.new(io)
        reader.each do |entry|
          full_name = entry.full_name
          if (entry.file?)
            directory.file(full_name).write_binary do |output|
              CottaFile.copy_io(entry, output)
            end
          elsif (entry.directory?)
            directory.dir(full_name).mkdirs
          end
        end
      end
      directory
    end

    # Create the zip file from current file
    # When target is nil, the output will be the name of the current file appended with ".zip"
    def zip(target = nil, level=nil, strategy=nil)
      target = parent.file("#{name}.zip") unless target
      read_binary do |read_io|
        target.write_binary do |write_io|
          gz = Zlib::GzipWriter.new(write_io, level, strategy)
          CottaFile.copy_io(read_io, gz)
          gz.close
        end
      end
      target
    end

    # unzips the file
    def unzip
      name = basename
      if (extname.length == 0)
        name = "#{name}.unzip"
      end
      target = parent.file(name)
      read_binary do |read_io|
        target.write_binary do |write_io|
          gz = Zlib::GzipReader.new(read_io)
          CottaFile.copy_io(gz, write_io)
          gz.close
        end
      end
      target
    end

    # copy from input handle to output handle
    def self::copy_io(input, output)
  #    output.write input.read
      while (content = input.read(1024)) do
        output.write content
      end
    end

    def ==(other)
      return false unless other.kind_of? CottaFile
      return factory.system == other.factory.system && @path == other.path
    end

    def to_s
      @path.to_s
    end

    def inspect
      return "#{self.class}:#{self.object_id}-#{factory.system.inspect}-#@path"
    end

  end
end
