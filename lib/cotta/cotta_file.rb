require 'fileutils'

module Cotta
class CottaFile
  include IoChain
  attr_reader :system, :path, :stat

  def initialize(system, path)
    @path = path
    @system = system
  end

  def cotta
    Cotta.new(@system)
  end

  def name
    return @path.basename.to_s
  end
  
  def extname
    return @path.extname
  end
  
  def basename
    return @path.basename(extname).to_s
  end
  
  def stat
    @system.file_stat(@path)
  end

  def older_than?(file)
    (stat <=> file.stat) == -1 
  end
  
  def exists?
    return @system.file_exists?(@path)
  end

  def relative_path_from(file_or_dir)
    path.relative_path_from(file_or_dir.path)
  end
  
  def parent
    return CottaDir.new(@system, @path.parent)
  end
  
  def copy_to(target_file)
    target_file.parent.mkdirs
    @system.copy_file(path, target_file.path)
    target_file
  end
  
  def copy_to_path(target_path)
    copy_to(cotta.file(target_path))
  end
  
  def move_to(target_file)
    target_file.parent.mkdirs
    @system.move_file(path, target_file.path)
  end
  
  def move_to_path(target_path)
    move_to(cotta.file(target_path))
  end
  
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

  def foreach()
    open('r') do |file|
      file.each {|line| yield line}
    end
  end
  
  def open(*args)
    result = f = @system.io(@path, *args)
    if block_given?
      begin
        result = yield f
      ensure
        f.close unless f.closed?
      end
    end
    result
  end

  def delete
    @system.delete_file(@path)
  end
  
  def extract(directory = nil)
    require 'rubygems/package'
    directory = parent.dir(basename) unless directory
    read_binary do |io|
      reader = Gem::Package::TarReader.new(io)
      reader.each do |entry|
        full_name = entry.full_name
        if (entry.file?)
          directory.file(full_name).write_binary do |output|
            copy_io(entry, output)
          end
        elsif (entry.directory?)
          directory.dir(full_name).mkdirs
        end
      end
    end
    directory
  end

  def zip(target = nil)
    target = parent.file("#{name}.zip") unless target
    read_binary do |read_io|
      target.write_binary do |write_io|
        gz = Zlib::GzipWriter.new(write_io)
        copy_io(read_io, gz)
        gz.close
      end
    end
    target
  end

  def unzip
    name = basename
    if (extname.length == 0)
      name = "#{name}.unzip"
    end
    target = parent.file(name)
    read_binary do |read_io|
      target.write_binary do |write_io|
        gz = Zlib::GzipReader.new(read_io)
        copy_io(gz, write_io)
        gz.close
      end
    end
    target
  end
  
  def ==(other)
    return false unless other.kind_of? CottaFile
    return @system == other.system && @path == other.path
  end
  
  def to_s
    @path.to_s
  end
  
  def inspect
    return "#{self.class}:#{self.object_id}-#{@system.inspect}-#@path"
  end
  
end
end
