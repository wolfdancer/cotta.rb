require 'spec'
require File.dirname(__FILE__) + '/../test'

module Cotta
describe FileFactory, 'zip support' do
  before do
    @cotta = FileFactory.new(InMemorySystem.new)
  end
  
  it 'extract from a tar file' do
    tar_file = FileFactory.parent_dir(__FILE__).file('tar_test.tar')
    dir = @cotta.dir('dir/extract')
    tar_file.extract(dir)
    dir.list.size.should == 3
    dir.file('one.txt').load.should == 'one'
    dir.file('two.txt').load.should == 'two'
    dir.file('three.txt').load.should == 'three'
  end
  
  it 'should archive files in the directory to a file' do
    source = @cotta.dir('dir/source')
    source.file('one.txt').save('one')
    source.file('two.txt').save('two')
    source.file('three.txt').save('three')
    tar_file = @cotta.file('target.tar')
    source.archive(tar_file)
    
    target_dir = @cotta.dir('target')
    tar_file.extract(target_dir)
    target_dir.file('one.txt').load.should == 'one'
    target_dir.file('two.txt').load.should == 'two'
    target_dir.file('three.txt').load.should == 'three'
    target_dir.should have(3).list
  end

  it 'archive subdirectories' do
      source = @cotta.dir('dir/source')
      sub = source.dir('sub')
      sub.file('one.txt').save('one')
      sub.file('two.txt').save('two')
      tar_file = @cotta.file('target.tar')
      source.archive(tar_file)

      target_dir = @cotta.dir('target')
      tar_file.extract(target_dir)
      target_dir.should have(1).list
      target_dir.dir('sub').should be_exists
      target_dir.dir('sub').should have(2).list
      target_dir.file('sub/one.txt').load.should == 'one'
      target_dir.file('sub/two.txt').load.should == 'two'
  end
end
end