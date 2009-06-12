require File.dirname(__FILE__) + '/../test'
require 'spec'
require 'pathname'

describe 'CottaDirBehaviors', :shared=>true do
  before do
    create_system
    @root = Cotta::CottaDir.new(@system, Pathname.new('.'))
    @dir = @root.dir('dir')
    @current = Dir.pwd
  end

  after do
    Dir.chdir @current
  end

  it 'load dir with basic information' do
    @dir.name.should == 'dir'
  end

  it 'should show path on to_s for convenience in scripting' do
    @dir.to_s.should == 'dir'
    "#{@dir}".should == 'dir'
  end

  it 'dir objects are value objects, equal on system and path' do
    (Cotta::CottaDir.new(@system, Pathname.new('dir')) == @dir).should == true
  end

  it 'dir should not be equal if path different' do
    (Cotta::CottaDir.new(@system, Pathname.new('/dir')) == @dir).should == false
  end

  it 'should support relative path' do
    sub_dir = @dir.dir('one/two/three')
    sub_dir.relative_path_from(@dir).to_s.should == 'one/two/three'
  end

  it 'should know its parent' do
    @dir.parent.name.should == '.'
    @dir.parent.parent.should be_nil
  end

  it 'should look up parent' do
    sub_dir = @dir.dir('one/two/three')
    result = sub_dir.parent {|dir| dir.name == 'one'}
    result.should == @dir.dir('one')
  end

  it 'should return nil if parent lookup fails' do
    sub_dir = @dir.dir('one/two/three')
    sub_dir.parent {|dir| false}.should be_nil
  end

  it 'should raise error if not exits stat' do
    Proc.new {
      @dir.stat
    }.should raise_error(Errno::ENOENT)
  end

  it 'support stat' do
    @dir.mkdirs
    @dir.stat.should_not be_nil
  end

  it 'dir should handle root dir' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('/root'))
    dir.parent.path.should == Pathname.new('/')
    dir.parent.name.should == '/'
    dir.parent.exists?.should == true
    dir.parent.root?.should == true
    dir.parent.parent.should be_nil
  end

  it 'dir should handle root dir for drive letters' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('C:/Windows'))
    dir.name.should == 'Windows'
    dir.parent.path.should == Pathname.new('C:/')
    dir.parent.name.should == 'C:/'
  end

  it 'dir should return sub directory' do
    @dir.dir('sub').path.should == Pathname.new('dir/sub')
    @dir.dir('sub').parent.should == @dir
  end

  it 'dir should return a directory from a relative pathname' do
    @dir.dir(Pathname.new('one/two/three')).should == @dir.dir('one').dir('two').dir('three')
  end

  it 'should get file in current directory' do
    file = @dir.file('file.txt')
    file.name.should == 'file.txt'
    file.path.should == Pathname.new('dir/file.txt')
    file.parent.should == @dir
  end

  it 'should create dir and its parent' do
    dir = @dir.dir('one').dir('two')
    dir.exists?.should == false
    dir.parent.exists?.should == false
    dir.mkdirs
    dir.exists?.should == true
    dir.parent.exists?.should == true
  end

  it 'should delete dir and its children' do
    dir = @dir.dir('one').dir('two').dir('three')
    dir.mkdirs
    @dir.exists?.should == true
    @dir.delete
    dir.exists?.should == false
    @dir.exists?.should == false
  end

  it 'should do nothing if dir does not exist' do
    dir = @dir.dir('one/two')
    dir.delete
    dir.delete
  end

  it 'should do nothing on mkdir if dir already exists' do
    dir = @dir.dir('one').dir('two')
    dir.mkdirs
    dir.mkdirs
  end

  it 'should list dirs' do
    @dir.dir('one').mkdirs
    @dir.file('one.txt').save
    actual_dir_list = @dir.list
    actual_dir_list.size.should == 2
    actual_dir_list[0].name.should == 'one'
    actual_dir_list[0].list.size.should == 0
    actual_dir_list[1].name.should == 'one.txt'
    actual_dir_list[1].save
  end

  it 'should move directory with its children' do
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

  it 'should copy directory with its children' do
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

  it 'dir takes relative path' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('targetdir/dir'))
    @dir.dir('one/two/three').mkdirs
    @dir.dir('one').exists?.should == true
    @dir.dir('one').dir('two').exists?.should == true
    @dir.dir('one').dir('two').dir('three').exists?.should == true
  end

  it 'list on not existing directory' do
    dir = Cotta::CottaDir.new(@system, Pathname.new('no/such/directory'))
    Proc.new {
      dir.list
    }.should raise_error(Errno::ENOENT)
  end

  it 'allow filter for archive' do
    @dir.file('in/in.txt').save('test')
    @dir.file('out/out.txt').save('test')
    result = @dir.archive {|entry|
      entry.name != 'out'
    }
    target = result.extract(@dir.dir('extract'))
    target.dir('out').should_not be_exist
    target.dir('in').should be_exist
  end

  it 'should support changing directory' do
    dir = @dir.dir('one/two')
    file = @dir.file('marker').save('marker')
    dir.mkdirs
    result = dir.chdir
    result.should == 0
    current = dir.cotta.pwd
    value = @root.chdir do
      dir.cotta.pwd.should == @root
      'value'
    end
    value.should == 'value'
    dir.cotta.pwd.should == current
  end

end
