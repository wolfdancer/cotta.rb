require 'spec'
dir = File.dirname(__FILE__)
require dir + '/../test'
require dir + '/file_system_behaviors'

module Cotta

describe PhysicalSystem do
  it_should_behave_like "FileSystemBehaviors"
  def create_system
    @system = PhysicalSystemStub.new
    @ios = Array.new
  end
  
  after do
    @ios.each {|io| io.close unless io.closed?}
  end

  it 'root directory always exists' do
    @system = PhysicalSystem.new
    @system.dir_exists?(Pathname.new('/')).should == true
    @system.dir_exists?(Pathname.new('D:/')).should == true
  end
  
  it 'shell command should return output' do
    @system = PhysicalSystem.new
    @system.shell('ruby --version')[0..3].should == 'ruby'
  end

  it 'should equals to any other physical system' do
    PhysicalSystem.new.should == PhysicalSystem.new
  end
end
end