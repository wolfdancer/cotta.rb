require 'spec'
dir = File.join(File.dirname(__FILE__))
require dir + '/cotta_file_behaviors'
require dir + '/../test'

module Cotta
  describe InMemorySystem, 'with cotta file' do
    it_should_behave_like 'CottaFileBehaviors'

    def create_system
      @system = InMemorySystem.new
    end

  end
end