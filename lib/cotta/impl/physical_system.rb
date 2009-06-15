module Cotta
  class PhysicalSystem
    def initialize
    end

    # Invoke the command passed in through the CommandRunner
    # and pass in the closure.
    def shell(command, &block)
      runner = CommandRunner.new(command)
      runner.execute(&block)
    end

    def environment!(variable)
      value = ENV[variable]
      raise "#{variable} environment variable not found" unless value
      return value
    end

    def environment(variable, default)
      value = ENV[variable]
      value = default unless value
      return value
    end

    def dir_exists?(dir_path)
      return FileTest.directory?(dir_path)
    end

    def file_exists?(file_path)
      return FileTest.file?(file_path)
    end

    def dir_stat(path)
      File.stat(path)
    end

    def file_stat(path)
      File.stat(path)
    end

    def list(dir_path)
      Dir.entries(dir_path).find_all {|item| item != '.' && item != '..'}
    end

    def mkdir(dir_path)
      Dir.mkdir(dir_path)
    end

    def io(file_path, argument)
      return File.open(file_path, argument)
    end

    def delete_file(file_path)
      return File.delete(file_path)
    end

    def delete_dir(dir_path)
      return Dir.delete(dir_path)
    end

    def copy_file(source, target)
      FileUtils.copy(source, target)
    end

    def move_file(source, target)
      FileUtils.move(source, target)
    end

    def copy_dir(source, target)
      FileUtils.copy_entry(source, target)
    end

    def move_dir(source, target)
      FileUtils.mv(source, target)
    end

    def chdir(target, &block)
      Dir.chdir(target, &block)
    end

    def pwd
      Dir.pwd
    end

    def ==(other)
      other.class == PhysicalSystem
    end

  end
end