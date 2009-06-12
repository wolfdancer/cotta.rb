require File.dirname(__FILE__) + '/../test'

module Cotta
describe CommandRunner do
  it 'return content' do
    runner = CommandRunner.new('ruby --version')
    runner.execute[0..3].should == 'ruby'
  end
  
  it 'raise error on abnormal exits' do
    runner = CommandRunner.new('ruby ----')
    Proc.new{runner.execute}.should raise_error(CommandError)
  end
  
  it 'take closure as io processor' do
    runner = CommandRunner.new('echo test')
    message_logged = nil
    runner.execute {|io| message_logged = io.gets}
    message_logged.should == "test\n"
  end
  
end

end
