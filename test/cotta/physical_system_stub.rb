module Cotta
class PhysicalSystemStub
  attr_reader :executed_commands

  def initialize
    @executed_commands = Array.new
    tmp_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'tmp'))
    @system = PhysicalSystem.new
    ensure_clean_directory(tmp_path)
    Dir.mkdir(File.join(tmp_path, 'current'))
    Dir.mkdir(File.join(tmp_path, 'root'))
    @tmp_path = Pathname.new(tmp_path)
  end
  
  def shell(command, &block)
    @executed_commands.push command
  end
  
  def dir_exists?(pathname)
    @system.dir_exists?(relative_from_tmp(pathname))
  end
  
  def file_exists?(pathname)
    @system.file_exists?(relative_from_tmp(pathname))
  end
  
  def dir_stat(pathname)
    @system.dir_stat(relative_from_tmp(pathname))
  end
  
  def file_stat(pathname)
    @system.file_stat(relative_from_tmp(pathname))
  end
  
  def list(pathname)
    @system.list(relative_from_tmp(pathname))
  end
  
  def mkdir(pathname)
    @system.mkdir(relative_from_tmp(pathname))
  end
  
  def delete_file(pathname)
    @system.delete_file(relative_from_tmp(pathname))
  end
  
  def delete_dir(pathname)
    @system.delete_dir(relative_from_tmp(pathname))
  end
  
  def io(pathname, arguments)
    @system.io(relative_from_tmp(pathname), arguments)
  end
  
  def copy_file(source, target)
    @system.copy_file(relative_from_tmp(source), relative_from_tmp(target))
  end
  
  def move_file(source, target)
    @system.move_file(relative_from_tmp(source), relative_from_tmp(target))
  end
  
  def copy_dir(source, target)
    @system.copy_dir(relative_from_tmp(source), relative_from_tmp(target))
  end
  
  def move_dir(source, target)
    @system.move_dir(relative_from_tmp(source), relative_from_tmp(target))
  end
  
  def copy_dir(source, target)
    @system.copy_dir(relative_from_tmp(source), relative_from_tmp(target))
  end
  
  def chdir(path, &block)
    @system.chdir(relative_from_tmp(path), &block)
  end
  
  def pwd
    path = @system.pwd
    candidate = relative_from_tmp(Pathname.new('/')).expand_path.to_s
    if (path.index(candidate) == 0)
      result = path[candidate.length, path.length - candidate.length]
    else
      candidate = relative_from_tmp(Pathname.new('.')).expand_path.to_s
      if candidate == path
        result = '.'
      else
        result = path[candidate.length + 1, path.length - candidate.length - 1]
      end
    end
    result
  end
  
  private
  def relative_from_tmp(pathname)
    tmp_pathname = nil
    if (pathname.absolute?)
      tmp_pathname = Pathname.new("root#{pathname}")
    else
      tmp_pathname = Pathname.new("current").join(pathname)
    end
    return @tmp_path.join(tmp_pathname)
  end
  
  def ensure_clean_directory(path)
    Dir.mkdir path unless File.directory? path
    Dir.foreach(path) do |name|
      if (name != '.' && name != '..')
        child_path = File.join(path, name)
        if (File.directory? child_path)
          ensure_clean_directory(child_path)
          Dir.rmdir(child_path)
        else
          File.delete(child_path)
        end
      end
    end
  end
    
end
end