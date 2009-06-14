require 'stringio'

module Cotta
class InMemorySystem
  
  attr_reader :executed_commands, :pwd

  def initialize
    @executed_commands = []
    @content = ""
    @file_system = Hash.new
    @file_system[nil] = DirectoryContent.new('')
    @file_system[Pathname.new('/')] = DirectoryContent.new('/')
    @file_system[Pathname.new('.')] = DirectoryContent.new('.')
    @output_map = Hash.new
  end
  
  def shell(command)
    @executed_commands.push(command)
    result = @output_map[command]
    raise "#{command} not found in expectation" unless result
    return result
  end
  
  def output_for_command(command, output)
    @output_map[command] = output
  end
  
  def expect_command(command)
    Entry.new(command)
  end

  def dir_exists?(pathname)
   content = path_content(pathname)
    return !content.nil? && content.directory?
  end
  
  def file_exists?(pathname)
    content = path_content(pathname)
    return !content.nil? && content.file?
  end
  
  def dir_stat(pathname)
    check_dir_exists(pathname)
    path_content(pathname).stat
  end
  
  def file_stat(pathname)
    check_file_exists(pathname)
    path_content(pathname).stat
  end
  
  def list(pathname)
    check_dir_exists(pathname)
    content = path_content(pathname)
    return content.children.collect {|item| item.name}
  end

  def check_dir_exists(pathname)
    raise Errno::ENOENT, pathname unless dir_exists? pathname
  end

  def check_file_exists(pathname)
    raise Errno::ENOENT, pathname unless file_exists? pathname
  end
  
  def mkdir(pathname)
    path_content!(pathname.cotta_parent).add(create_dir(pathname))
  end
  
  def io(*args)
    file_content = retrieve_file_content(args[0], args[1])
    return StringIO.new(file_content.content, *args[1, args.size - 1])
  end
  
  def copy(source, target)
    copy_file(source, target)
  end
  
  def copy_file(source, target)
    file_content = retrieve_file_content(source, 'r').content
    create_file(target).content = file_content.clone
  end
  
  def move(source, target)
    move_file(source, target)
  end
  
  def move_file(source, target)
    copy(source, target)
    delete_file(source)
  end
  
  def copy_dir(source, target)
    check_dir_exists(source)
    mkdir(target)
    path_content(source).children.each do |item|
      item.copy_to_dir(self, source, target)
    end
  end
  
  def move_dir(source, target)
    copy_dir(source, target)
    delete_dir(source)
  end
  
  def delete_file(pathname)
    raise Errno::ENOENT.new(pathname) unless file_exists? pathname
    delete_entry(pathname)
  end
  
  def delete_dir(pathname)
    raise Errno::ENOENT.new(pathname) unless dir_exists? pathname
    delete_entry(pathname)
  end
  
  def to_s
    return 'InMemorySystem'
  end
  
  def chdir(path)
    last_pwd = @pwd
    @pwd = path.to_s
    result = 0
    if (block_given?)
      begin
        result = yield
      ensure
        @pwd = last_pwd
      end
    end
    result
  end
  
  private
  def gather_paths_to_create(pathname)
    paths = Array.new
    path_to_create = pathname   
    while (! dir_exists?(path_to_create))
      paths.push(path_to_create)
      path_to_create = path_to_create.cotta_parent
    end
    return paths
  end  
  
  def create_dir(pathname)
    content = DirectoryContent.new(pathname.basename.to_s)
    @file_system[pathname] = content
    return content
  end
  
  def create_file(pathname)
    content = FileContent.new(pathname.basename.to_s)
    parent_dir = pathname.cotta_parent
    path_content(parent_dir).add(content)
    @file_system[pathname] = content
    return content
  end
  
  def path_content(pathname)
    content = path_content!(pathname)
    if (content.nil? && pathname.cotta_parent.nil?)
      mkdir(pathname)
      content = @file_system[pathname]
    end
    return content
  end
  
  def path_content!(pathname)
    @file_system[pathname]
  end
  
  def retrieve_file_content(pathname, options)
    file_content = path_content(pathname)
    if (file_content.nil?)
      if (options =~ /r/)
        raise Errno::ENOENT.new(pathname)
      end
      file_content = create_file(pathname)
    end
    if (options =~ /w/)
      file_content.touch
    end
    return file_content
  end
  
  def delete_entry(pathname)
    @file_system.delete pathname
    @file_system[pathname.cotta_parent].delete(pathname.basename.to_s)
  end
    
end

class DirectoryContent
  attr_reader :name, :children, :stat

  def initialize(name)
    @name = name
    @children = Array.new
    @stat = ContentStat.new(self)
  end 

  def file?
    return false
  end
  
  def directory?
    return true
  end
  
  def add(content)
    @children.push(content)
  end
  
  def delete(name)
    @children.delete_if {|file_content| file_content.name == name}
  end
  
  def copy_to_dir(system, parent_dir, target_dir)
    source_path = parent_dir.join(name)
    target_path = target_dir.join(name)
    system.copy_dir(source_path, target_path)
  end
end

class FileContent
  attr_reader :name, :content, :stat
  attr_writer :content
  
  def initialize(name)
    @name = name
    @content = ''
    @stat = ContentStat.new(self)
  end
  
  def file?
    return true
  end
  
  def directory?
    return false
  end
  
  def size
    content.size
  end
  
  def copy_to_dir(system, parent_dir, target_dir)
    target_path = target_dir.join(name)
    source_path = parent_dir.join(name)
    system.copy_file(source_path, target_path)
  end

  def touch
    @stat.touch
  end
end

class ContentStat
  attr_reader :mtime

  def initialize(content)
    @content = content
    @mtime = Time.new
  end
  
  def mode
    '10777'
  end
  
  def size
    @content.size
  end

  def file?
    @content.file?
  end

  def directory?
      @content.directory?
  end

  def touch
    @mtime = Time.new
  end

  def writable?
    true
  end

  def <=> stat
    mtime <=> stat.mtime
  end
end
end