module Cotta
  # This class represents a directory
  class CottaDir
    # Path of the directory
    attr_reader :path
    
    # file factory of the directory
    attr_reader :factory

    # Create an instance of CottaDir that is on
    # the given path and
    # backed by the given system
    def initialize(factory, path)
      @path = path
      @factory = factory
      @name = @path.basename.to_s
    end

    # name of the directory
    def name
      name = nil
      if root?
        name = path.to_s
      else
        name = @path.basename.to_s
      end
      return name
    end

    # returns true if this directory is the root directory
    def root?
      parent.nil?
    end

    # returns true if this directory exists
    def exists?
      factory.system.dir_exists?(@path)
    end

    # returns the stat of the current directory
    def stat
      factory.system.dir_stat(@path)
    end

    # returns the parent directory of this directory
    # or nil if this is root
    def parent
      parent_path = @path.cotta_parent
      return nil unless parent_path
      candidate = CottaDir.new(factory, parent_path)
      if (block_given?)
        candidate = candidate.parent until candidate.nil? or yield candidate
      end
      candidate
    end

    # returns the relative path from the given file or directory
    def relative_path_from(entry)
      @path.relative_path_from(entry.path)
    end

    # returns the sub-directory with the given name
    def dir(name)
      return CottaDir.new(factory, @path.join(name))
    end

    # returns the file under this directory with the given name
    def file(name)
      return CottaFile.new(factory, @path.join(name))
    end

    # creates this directory and its parent directory
    def mkdirs
      if (not exists?)
        parent.mkdirs
        factory.system.mkdir @path
      end
    end

    # deletes this directory and all its children
    def delete
      if (exists?)
        list.each do |children|
          children.delete
        end
        factory.system.delete_dir(@path)
      end
    end

    # move this directory to target directory
    # this method assumes that this directory and the target directory
    # are backed by the same file system
    def move_to(target)
      target.parent.mkdirs
      factory.system.move_dir(@path, target.path)
    end

    # move this directory to target path
    # this method assumes that this directory and the target directory
    # are backed by the same file system
    def move_to_path(target_path)
      move_to(cotta.dir(target_path))
    end

    # copy this directory to target directory
    # this method assumes that this directory and the target directory
    # are backed by the same file system
    def copy_to(target)
      target.parent.mkdirs
      factory.system.copy_dir(@path, target.path)
    end

    # archive this directory and call the given block
    # to determine if a file or directory should be included
    def archive(target = nil, &block)
      require 'rubygems/package'
      unless target
        target = parent.file("#{name}.tar")
      end
      target.write_binary do |io|
        writer = Gem::Package::TarWriter.new(io) do |tar_io|
          archive_dir(tar_io, self, &block)
        end
      end
      target
    end

    def archive_dir(tar_io, dir, &block)
      dir.list.each do |child|
        if (block_given? and not yield child)
          next
        end
        stat = child.stat
        entry_name = child.relative_path_from(self).to_s
        mode = stat.mode
        if (stat.file?)
          tar_io.add_file(entry_name, mode) do |entry_output|
            child.read_binary do |input|
              CottaFile.copy_io(input, entry_output)
            end
          end
        elsif (stat.directory?)
          tar_io.mkdir(entry_name, mode)
          archive_dir(tar_io, child, &block)
        end
      end
    end

    private :archive_dir

    def copy_to_path(target_path)
      copy_to(cotta.dir(target_path))
    end

    # returns the content of this directory
    # as an array of CottaFile and CottaDirectory
    def list
      factory.system.list(@path).collect do |item|
        candidate = dir(item)
        if (not candidate.exists?)
          candidate = file(item)
        end
        candidate
      end
    end

    def chdir(&block)
      factory.system.chdir(@path, &block)
    end

    def ==(other)
      return @path == other.path && factory.system == other.factory.system
    end

    def inspect
      return "#{self.class}:#{self.object_id}-#@path"
    end

    def to_s
      @path.to_s
    end

  end
end
