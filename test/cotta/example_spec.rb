require 'spec'

require File.dirname(__FILE__) + '/../test'

describe Cotta do
  it 'should run example' do
    #system implementation is injected here
    cotta = Cotta::Cotta.new(Cotta::InMemorySystem.new)
    file = cotta.file('dir/file.txt')
    file.should_not be_exists
    # parent directories are created automatically
    file.save('my content')
    file2 = cotta.file('dir/file2.txt')
    file2.should_not be_exists
    file.copy_to(file2)
    file2.should be_exists
    file2.load.should == 'my content'
    file2.read {|file| puts file.gets}
  end
end