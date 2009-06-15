require 'spec'

dir = File.dirname(__FILE__)
require dir + '/../test'
require dir + '/cotta_dir_behaviors'

describe Cotta::InMemorySystem, 'with Cotta Dir' do
  it_should_behave_like 'CottaDirBehaviors'

  def create_system
    @system = Cotta::InMemorySystem.new
  end

  it 'dir should not be equal if system different' do
    (Cotta::CottaDir.new(Cotta::InMemorySystem.new, Pathname.new('dir')) == @dir).should == false
  end

  it 'to_s and inspect' do
    file = Cotta::CottaFile.new(@system, '/one/two/file.txt')
    "#{file.to_s}".should == '/one/two/file.txt'
  end

end
