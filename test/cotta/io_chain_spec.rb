require 'spec'
dir = File.dirname(__FILE__)
require dir + '/../test'
require dir + '/physical_system_stub'

module Cotta
module IoChain
  describe IoChain do
    include IoChain
    before do
      @cotta = Cotta.new(PhysicalSystemStub.new)
    end

    it 'copy binary io' do
      file = Cotta.parent_of(__FILE__).file('logo.gif')
      target = @cotta.file('target.gif')
      file.read_binary do |input|
        target.write_binary do |output|
          copy_io(input, output)
        end
      end
      expect_stat = file.stat
      actual_stat = target.stat
      actual_stat.size.should == expect_stat.size
    end
  end
end
end