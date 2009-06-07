require 'spec'

require File.dirname(__FILE__) + '/../../../lib/Cotta/cotta'

module Cotta
describe CommandInterface do
  it 'delegate output to io' do
    io = mock('io')
    io.should_receive(:puts).with('content to output')
    interface = CommandInterface.new(io)
    interface.puts('content to output')
  end
  
  it 'prompt outputs a message and get the response from io' do
    io = mock('io')
    io.should_receive(:puts).with('question')
    io.should_receive(:gets).and_return('answer')
    interface = CommandInterface.new(io)
    actual = interface.prompt('question')
    actual.should == 'answer'
  end
    
  it 'prompt for choice' do
    io = mock('io')
    io.should_receive(:puts).once.with('select one of the following')
    io.should_receive(:puts).once.with('[1] item one')
    io.should_receive(:puts).once.with('[2] item two')
    io.should_receive(:gets).once.and_return('2')
    interface = CommandInterface.new(io)
    actual = interface.prompt_for_choice('select one of the following', ['item one', 'item two'])
    actual.should == 'item two'
  end
  
  it 'prompt for choice returns nil for invalid choice' do
    io = mock('io')
    io.should_receive(:puts).with('select one')
    io.should_receive(:puts).exactly(2).times
    io.should_receive(:gets).and_return('9')
    interface = CommandInterface.new(io)
    actual = interface.prompt_for_choice('select one', ['one', 'two'])
    actual.should be_nil
  end
end
end