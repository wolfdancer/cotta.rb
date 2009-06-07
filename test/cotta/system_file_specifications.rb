require File.dirname(__FILE__) + '/../../../lib/Cotta/cotta'
require 'pathname'

  def register_system_file_specifications
      
      specify 'current directory always exists' do
        @system.dir_exists?(Pathname.new('.')).should == true
      end
      
      specify 'mkdir should create directory' do
        pathname = Pathname.new('/one')
        @system.dir_exists?(pathname).should == false
        @system.mkdir(pathname)
        @system.dir_exists?(pathname).should == true
      end
      
      specify 'mkdir raise error if dir already exists' do
        pathname = Pathname.new('/one')
        @system.mkdir(pathname)
        lambda {@system.mkdir}.should_raise StandardError
      end
      
      specify 'io returns IO handle' do
        pathname = Pathname.new('file.txt')
        @system.file_exists?(pathname).should == false
        write_io = load_io(pathname, 'w')
        write_io.puts 'content'
        write_io.close
        @system.file_exists?(pathname).should == true
        read_io = load_io(pathname, 'r')
        read_io.gets.should == "content\n"
        read_io.close
        @system.delete_file(pathname)
      end
      
      specify 'file creation should leave file system consistent' do
        pathname = Pathname.new('dir/sub/file.txt')
        @system.mkdir(pathname.parent.parent)
        @system.mkdir(pathname.parent)
        @system.file_exists?(pathname).should == false
        @system.dir_exists?(pathname.parent).should == true
        load_io(pathname, 'w').close
        @system.file_exists?(pathname).should == true
        @system.dir_exists?(pathname).should == false
        @system.dir_exists?(pathname.parent).should == true
        children = @system.list(pathname.parent)
        children.size.should == 1
        children[0].should == pathname.basename.to_s
      end
      
      specify 'directory creation should leave file system consistent' do
        pathname = Pathname.new('root/dir/sub')
        @system.dir_exists?(pathname).should == false
        @system.file_exists?(pathname).should == false
        @system.dir_exists?(pathname.parent).should == false
        @system.mkdir(pathname.parent.parent)
        @system.mkdir(pathname.parent)
        @system.mkdir(pathname)
        @system.dir_exists?(pathname).should == true
        @system.file_exists?(pathname).should == false
        @system.dir_exists?(pathname.parent).should == true
        list = @system.list(pathname.parent)
        list.size.should == 1
        list[0].should ==(pathname.basename.to_s)
      end
      
      specify 'read io should raise error if file does not exists' do
        pathname = Pathname.new('dir/file.txt')
        Proc.new {@system.io(pathname, 'r')}.should_raise Errno::ENOENT
      end
      
      specify 'delete dir' do
        pathname = Pathname.new('dir')
        @system.mkdir(pathname)
        @system.delete_dir(pathname)
        @system.dir_exists?(pathname).should == false
      end
      
      specify 'deleting dir that does not exist should raise error' do
        pathname = Pathname.new('dir/dir2')
        Proc.new {@system.delete_dir(pathname)}.should_raise Errno::ENOENT
      end
      
      specify 'copy file' do
        pathname = Pathname.new('file1')
        write_io = load_io(pathname, 'w')
        write_io.puts 'line'
        write_io.close
        target = Pathname.new('target')
        @system.copy_file(pathname, target)
        @system.file_exists?(target).should == true
        read_io = load_io(target, 'r')
        read_io.gets.should == "line\n"
        read_io.close
      end
      
      specify 'move file' do
        pathname = Pathname.new('file1')
        write_content(pathname, 'line')
        target = Pathname.new('target')
        @system.move_file(pathname, target)
        @system.file_exists?(target).should == true
        read_io = load_io(target, 'r')
        read_io.gets.should == "line\n"
        read_io.close
        @system.file_exists?(pathname).should == false
      end
      
      specify 'move dir' do
        source = Pathname.new('source')
        @system.mkdir source
        source_file = Pathname.new('source/file.txt')
        write_content(source_file, 'file.txt')
        @system.mkdir source.join('subdir')
        target = Pathname.new('target')
        @system.move_dir(source, target)
        @system.list(target).size.should == 2
        @system.dir_exists?(source).should == false
        @system.dir_exists?(target).should == true
        @system.file_exists?(Pathname.new('target/file.txt')).should == true
        @system.dir_exists?(Pathname.new('target/subdir')).should == true
      end
      
      specify 'copy dir' do
        source = Pathname.new('source')
        @system.mkdir source
        source_file = Pathname.new('source/file.txt')
        write_content(source_file, 'file.txt')
        @system.mkdir source.join('subdir')
        target = Pathname.new('target')
        @system.copy_dir(source, target)
        @system.list(target).size.should == 2
        @system.dir_exists?(source).should == true
        @system.dir_exists?(target).should == true
        @system.file_exists?(Pathname.new('target/file.txt')).should == true
      end
      
      def write_content(pathname, content)
        write_io = load_io(pathname, 'w')
        write_io.puts content
        write_io.close
      end

  end    
  def load_io(*args)
    io = @system.io(*args)
    if (io)
      @ios.push(io)
    else
      raise "IO is null for: #{args}"
    end
    return io
  end
