require File.dirname(__FILE__) + '/../../../lib/Cotta/cotta'
require 'spec'
require 'pathname'

module CottaSpecifications

def register_cotta_file_specifications
  setup do
    @file = Cotta::CottaFile.new(@system, Pathname.new('dir/file.txt'))
  end

  specify 'file can be created with system and pathname' do
    @file.name.should == 'file.txt'
    @file.path.should == Pathname.new('dir/file.txt')
    @file.exists?.should == false
  end
  
  specify 'file should know properties like parent, name, etc.' do
    @file.parent.should == Cotta::CottaDir.new(@system, Pathname.new('dir'))
    @file.name.should == 'file.txt'
    @file.path.should == Pathname.new('dir/file.txt')
    @file.extname.should == '.txt'
    @file.basename.should == 'file'
  end

  specify 'should support relative path' do
    parent = @file.parent
    file = parent.file('one/two/three.txt')
    file.relative_path_from(parent).to_s.should == 'one/two/three.txt'  
  end
  
  specify 'file should support stat' do
    @file.save('test')
    @file.stat.should_not_be_nil
    @file.stat.size.should == 4
    @file.stat.writable?.should == true
  end

  specify 'should raise error if does not exist' do
    Proc.new {@file.stat}.should_raise Errno::ENOENT
  end
  
  specify 'should load and save file content' do
    @file.exists?.should == false
    @file.parent.exists?.should == false
    @file.save("content to save\nsecond line")
    @file.exists?.should == true
    @file.load.should ==("content to save\nsecond line")
  end
  
  specify 'should open file to read' do
    @file.save("one\ntwo")
    @file.read do |file|
      file.gets.should ==("one\n")
      file.gets.should ==('two')
    end
  end
  
  specify 'should equal if same system and pathname' do
    file2 = Cotta::CottaFile.new(@system, Pathname.new('dir/file.txt'))
    file2.should == @file
  end
  
  specify 'should copy to another file' do
    file2 = Cotta::CottaFile.new(@system, Pathname.new('dir2/file.txt'))
    file2.exists?.should == false
    @file.save('my content')
    @file.copy_to(file2)
    file2.exists?.should == true
    file2.load.should == 'my content'
  end
  
  specify 'should move file' do
    file2 = Cotta::CottaFile.new(@system, Pathname.new('dir2/file.txt'))
    file2.exists?.should == false
    @file.save('content')
    @file.move_to(file2)
    file2.exists?.should == true
    file2.load.should == 'content'
    @file.exists?.should == false
  end
  
  specify 'should support foreach' do
    @file.write do |file|
      file.puts 'line one'
      file.puts 'line two'
    end
    collected = Array.new
    @file.foreach do |line|
      collected.push line
    end
    collected.size.should == 2
    collected[0].should == "line one\n"
    collected[1].should == "line two\n"
  end
  
  specify 'should delete file' do
    @file.save
    @file.exists?.should == true
    @file.delete
    @file.exists?.should == false
  end
  
  specify 'should raise error if file to delete does not exist' do
    lambda {@file.delete}.should_raise Errno::ENOENT
  end

  specify 'should check timestamp to see which one is older' do
    @file.save
    file2 = @file.parent.file('another.txt')
    sleep 1
    file2.save
    @file.older_than?(file2).should == true
    file2.older_than?(@file).should == false
  end

end

def register_cotta_dir_specifications
  setup do
    @dir = Cotta::CottaDir.new(@system, Pathname.new('dir'))
  end

  specify 'load dir with basic information' do
    @dir.name.should == 'dir'
  end
  
  specify 'dir objects are value objects, equal on system and path' do
    (Cotta::CottaDir.new(@system, Pathname.new('dir')) == @dir).should == true
  end
  
  specify 'dir should not be equal if path different' do
    (Cotta::CottaDir.new(@system, Pathname.new('/dir')) == @dir).should == false
  end

  specify 'should support relative path' do
    sub_dir = @dir.dir('one/two/three')
    sub_dir.relative_path_from(@dir).to_s.should == 'one/two/three'
  end
  
  specify 'dir should know its parent' do
    @dir.parent.name.should == '.'
    @dir.parent.parent.should_be nil
  end
  
  specify 'should raise error if not exits stat' do
    Proc.new {@dir.stat}.should_raise Errno::ENOENT
  end
  
  specify 'support stat' do
    @dir.mkdirs
    @dir.stat.should_not_be_nil
  end
  
  specify 'dir should handle root dir' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('/root'))
    dir.parent.path.should == Pathname.new('/')
    dir.parent.name.should == '/'
    dir.parent.exists?.should == true
    dir.parent.root?.should == true
    dir.parent.parent.should_be nil
  end
  
  specify 'dir should handle root dir for drive letters' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('C:/Windows'))
    dir.name.should == 'Windows'
    dir.parent.path.should == Pathname.new('C:/')
    dir.parent.name.should == 'C:/'
  end
  
  specify 'dir should return sub directory' do
    @dir.dir('sub').path.should == Pathname.new('dir/sub')
    @dir.dir('sub').parent.should == @dir
  end
  
  specify 'dir should return a directory from a relative pathname' do
    @dir.dir(Pathname.new('one/two/three')).should == @dir.dir('one').dir('two').dir('three')
  end
  
  specify 'should get file in current directory' do
    file = @dir.file('file.txt')
    file.name.should == 'file.txt'
    file.path.should == Pathname.new('dir/file.txt')
    file.parent.should == @dir
  end
  
  specify 'should create dir and its parent' do
    dir = @dir.dir('one').dir('two')
    dir.exists?.should == false
    dir.parent.exists?.should == false
    dir.mkdirs
    dir.exists?.should == true
    dir.parent.exists?.should == true
  end
  
  specify 'should delete dir and its children' do
    dir = @dir.dir('one').dir('two').dir('three')
    dir.mkdirs
    @dir.exists?.should == true
    @dir.delete
    dir.exists?.should == false
    @dir.exists?.should == false
  end
  
  specify 'should do nothing if dir already exists' do
    dir = @dir.dir('one').dir('two')
    dir.mkdirs
    dir.mkdirs
  end
  
  specify 'should list dirs' do
    @dir.dir('one').mkdirs
    @dir.file('one.txt').save
    actual_dir_list = @dir.list
    actual_dir_list.size.should == 2
    actual_dir_list[0].name.should == 'one'
    actual_dir_list[0].list.size.should == 0
    actual_dir_list[1].name.should == 'one.txt'
    actual_dir_list[1].save
  end
  
  specify 'should move directory with its children' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('targetdir/child_dir'))
    @dir.file('file.txt').save('file.txt')
    @dir.dir('subdir').mkdirs
    @dir.list.size.should == 2
    @dir.move_to(dir)
    @dir.exists?.should == false
    dir.list.size.should == 2
    dir.file('file.txt').load.should == 'file.txt'
    dir.dir('subdir').exists?.should == true
  end
  
  specify 'should copy directory with its children' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('targetdir/child_dir'))
    @dir.file('file.txt').save('file.txt')
    @dir.dir('subdir').mkdirs
    @dir.list.size.should == 2
    @dir.copy_to(dir)
    @dir.exists?.should == true
    dir.list.size.should == 2
    dir.file('file.txt').load.should == 'file.txt'
    dir.dir('subdir').exists?.should == true
  end
  
  specify 'dir takes relative path' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('targetdir/dir'))
    @dir.dir('one/two/three').mkdirs
    @dir.dir('one').exists?.should == true
    @dir.dir('one').dir('two').exists?.should == true
    @dir.dir('one').dir('two').dir('three').exists?.should == true
  end
  
  specify 'list on not existing directory' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('no/such/directory'))
    Proc.new {dir.list}.should_raise Errno::ENOENT
  end

  specify 'allow filter for archive' do
    @dir.file('in/in.txt').save('test')
    @dir.file('out/out.txt').save('test')
    result = @dir.archive {|entry| entry.name != 'out'}
    target = result.extract(@dir.dir('extract'))
    target.dir('out').should_not_be_exist
    target.dir('in').should_be_exist
  end
  
end

end