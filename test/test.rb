require File.dirname(__FILE__) + '/../lib/cotta'
require File.dirname(__FILE__) + '/cotta/physical_system_stub'
require 'spec'

module Cotta
  module TempDirs
    def setup_tmp
      root = current(__FILE__).parent {|dir| dir.name == 'buildmaster' and dir.dir('bin').exists?}
      output = root.dir('tmp')
      output.delete
      output
    end

    def current(file)
      FileFactory.file(file).parent
    end

  end
end