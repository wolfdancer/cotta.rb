require 'pathname'
require File.dirname(__FILE__) + '/cotta/impl/io_chain'
require File.dirname(__FILE__) + '/cotta/cotta_dir'
require File.dirname(__FILE__) + '/cotta/cotta_file'
require File.dirname(__FILE__) + '/cotta/impl/cotta_pathname'
require File.dirname(__FILE__) + '/cotta/impl/in_memory_system'
require File.dirname(__FILE__) + '/cotta/impl/physical_system'
require File.dirname(__FILE__) + '/cotta/command_error'
require File.dirname(__FILE__) + '/cotta/command_interface'
require File.dirname(__FILE__) + '/cotta/file_not_found_error'
require File.dirname(__FILE__) + '/cotta/impl/command_runner'
require File.dirname(__FILE__) + '/cotta/file_factory'

# Cotta module that contains all the classes used for file operations
# see link:files/README.html
module Cotta
  # Creates CottaFile repersenting physical file
  def self.file(path)
    FileFactory.file(path)
  end

  # Creates CottaDir representing physical directory
  def self.dir(path)
    FileFactory.dir(path)
  end

  # Creates CottaDir that is the parent of the path
  # This is typically used with __FILE__
  # e.g. dir = Cotta.parent_dir(__FILE__)
  def self.parent_dir(path)
    FileFactory.parent_dir(path)
  end

end