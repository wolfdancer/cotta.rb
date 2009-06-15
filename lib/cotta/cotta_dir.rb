module Cotta
  # This class represents a directory
  class CottaDir
    include IoChain
    attr_reader :path, :system

    def initialize(system, path)
      @path = path
      @system = system
      @name = @path.basename.to_s
    end

    def cotta
      FileFactory.new(@system)
    end

    def name
      name = nil
      if root?
        name = path.to_s
      else
        name = @path.basename.to_s
      end
      return name
    end

    def root?
      parent.nil?
    end

    def exists?
      return @system.dir_exists?(@path)
    end

    def stat
      @system.dir_stat(@path)
    end

    def parent
      parent_path = @path.cotta_parent
      return nil unless parent_path
      candidate = CottaDir.new(@system, parent_path)
      if (block_given?)
        candidate = candidate.parent until candidate.nil? or yield candidate
      end
      candidate
    end

    def relative_path_from(entry)
      @path.relative_path_from(entry.path)
    end

    def dir(name)
      return CottaDir.new(@system, @path.join(name))
    end

    def file(name)
      return CottaFile.new(@system, @path.join(name))
    end

    def mkdirs
      if (not exists?)
        parent.mkdirs
        @system.mkdir @path
      end
    end

    def delete
      if (exists?)
        list.each {|children|
          children.delete
        }
        @system.delete_dir(@path)
      end
    end

    def move_to(target)
      target.parent.mkdirs
      @system.move_dir(@path, target.path)
    end

    def move_to_path(target_path)
      move_to(cotta.dir(target_path))
    end

    def copy_to(target)
      target.parent.mkdirs
      @system.copy_dir(@path, target.path)
    end

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
              copy_io(input, entry_output)
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

    def list
      @system.list(@path).collect do |item|
        candidate = dir(item)
        if (not candidate.exists?)
          candidate = file(item)
        end
        candidate
      end
    end

    def chdir(&block)
      @system.chdir(@path, &block)
    end

    def ==(other)
      return @path == other.path && @system == other.system
    end

    def inspect
      return "#{self.class}:#{self.object_id}-#@path"
    end

    def to_s
      @path.to_s
    end

  end
end
