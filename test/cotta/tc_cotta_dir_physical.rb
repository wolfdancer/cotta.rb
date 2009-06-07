require 'spec'
require File.join(File.dirname(__FILE__)) + '/../test'
require File.join(File.dirname(__FILE__)) + '/cotta_dir_behaviors'

module Cotta
describe PhysicalSystem, 'work with CottaDir' do
  it_should_behave_like 'CottaDirBehaviors'

  def create_system
    @system = PhysicalSystemStub.new
  end
  
end
end
