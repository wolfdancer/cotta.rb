require 'spec'
dir = File.dirname(__FILE__)
require dir + '/../test'
require dir + '/cotta_file_behaviors'
require dir + '/physical_system_stub'

module Cotta
describe PhysicalSystem, 'with cotta file' do
  it_should_behave_like 'CottaFileBehaviors'

  def create_system
    @system = Cotta.factory(PhysicalSystemStub.new)
  end

  before do
    create_system unless @system
  end
  
  it 'copying binary files properly' do
    logo_gif = FileFactory.parent_dir(__FILE__).file('logo.gif')
    content = logo_gif.read_binary {|io| io.read}
    target = CottaFile.new(@system, Pathname.new('dir/logo.gif'))
    target.parent.mkdirs
    target.write_binary do |io|
      io.write content
    end
    expected_stat = logo_gif.stat
    actual_stat = target.stat
    actual_stat.size.should == expected_stat.size
  end

  it 'zip and unzip' do
    logo_gif = FileFactory.parent_dir(__FILE__).file('logo.gif')
    content = logo_gif.read_binary {|io| io.read}
    dir = CottaDir.new(@system, Pathname.new('dir'))
    target_dir = dir.dir('target')
    target_dir.file(logo_gif.name).write_binary {|io| io.write content}
    zip_file = target_dir.archive.zip
    extract_dir = dir.dir('extract')
    file_to_unzip = zip_file.copy_to(extract_dir.file(zip_file.name))
    extracted_dir = file_to_unzip.unzip.extract

    extracted_dir.file('logo.gif').stat.size.should == logo_gif.stat.size
  end

end
end