require File.dirname(__FILE__) + '/../test'
require 'spec'
require 'pathname'

module Cotta
  describe 'CottaFileBehaviors', :shared => true do
    before do
      create_system
      @file = CottaFile.new(@system, Pathname.new('dir/file.txt'))
    end
    it 'file can be created with system and pathname' do
      @file.name.should == 'file.txt'
      @file.path.should == Pathname.new('dir/file.txt')
      @file.exists?.should == false
    end

    it 'should return path on to_s for scripting convenience' do
      @file.to_s.should == 'dir/file.txt'
      "#{@file}".should == 'dir/file.txt'
    end

    it 'file should know properties like parent, name, etc.' do
      @file.parent.should == CottaDir.new(@system, Pathname.new('dir'))
      @file.name.should == 'file.txt'
      @file.path.should == Pathname.new('dir/file.txt')
      @file.extname.should == '.txt'
      @file.basename.should == 'file'
    end

    it 'should support relative path' do
      parent = @file.parent
      file = parent.file('one/two/three.txt')
      file.relative_path_from(parent).to_s.should == 'one/two/three.txt'
    end

    it 'file should support stat' do
      @file.save('test')
      @file.stat.should_not be_nil
      @file.stat.size.should == 4
      @file.stat.writable?.should == true
    end

    it 'should raise error if does not exist' do
      Proc.new {
        @file.stat
      }.should raise_error(Errno::ENOENT)
    end

    it 'should load and save file content' do
      @file.exists?.should == false
      @file.parent.exists?.should == false
      @file.save("content to save\nsecond line")
      @file.exists?.should == true
      @file.load.should ==("content to save\nsecond line")
    end

    it 'should open file to read' do
      @file.save("one\ntwo")
      @file.read do |file|
        file.gets.should ==("one\n")
        file.gets.should ==('two')
      end
    end

    it 'should equal if same system and pathname' do
      file2 = CottaFile.new(@system, Pathname.new('dir/file.txt'))
      file2.should == @file
    end

    it 'should copy to another file' do
      file2 = CottaFile.new(@system, Pathname.new('dir2/file.txt'))
      file2.exists?.should == false
      @file.save('my content')
      @file.copy_to(file2)
      file2.exists?.should == true
      file2.load.should == 'my content'
    end

    it 'should move file' do
      file2 = CottaFile.new(@system, Pathname.new('dir2/file.txt'))
      file2.exists?.should == false
      @file.save('content')
      @file.move_to(file2)
      file2.exists?.should == true
      file2.load.should == 'content'
      @file.exists?.should == false
    end

    it 'should support foreach' do
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

    it 'should delete file' do
      @file.save
      @file.exists?.should == true
      @file.delete
      @file.exists?.should == false
    end

    it 'should raise error if file to delete does not exist' do
      lambda {
        @file.delete
      }.should raise_error(Errno::ENOENT)
    end

    it 'should check timestamp to see which one is older' do
      @file.save
      file2 = @file.parent.file('another.txt')
      sleep 1
      file2.save
      file2.older_than?(@file).should == false
      @file.older_than?(file2).should == true
    end

  end

end