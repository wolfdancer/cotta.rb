require 'spec'

require File.dirname(__FILE__) + '/../test'

describe Cotta do
  before do
    # Given
    @system = Cotta::InMemorySystem.new
    @cotta = Cotta::FileFactory.new(@system)
  end
  
=begin not for release 1.0
  it 'shell out command to system' do
    # Given
    # When
    @system.output_for_command('shell command', 'test')
    @cotta.shell('shell command')
    # Ensure
    @system.executed_commands.length.should== 1
    @system.executed_commands[0].should == 'shell command'
  end
=end
  
  it 'instantiate dir from cotta' do
    dir = @cotta.dir('dirname')
    dir.name.should == 'dirname'
  end
  
  it 'instantiate file from cotta' do
    file = @cotta.file('one/two/three.txt')
    file.name.should == 'three.txt'
    file.parent.name.should == 'two'
  end
  
  it 'entry creates file or directory based on which one exists' do
    @cotta.file('file').save
    @cotta.dir('dir').mkdirs
    @cotta.entry('file').should be_exist
    @cotta.entry('dir').should be_exist
  end
  
  it 'nil in, nil out' do
    @cotta.file(nil).should be_nil
    @cotta.dir(nil).should be_nil
    Cotta.file(nil).should be_nil
    Cotta.dir(nil).should be_nil
  end
  
  it 'create parent directory directly from __FILE__' do
    actual = Cotta.parent_dir(__FILE__)
    actual.name.should == 'cotta'
  end
  
end
