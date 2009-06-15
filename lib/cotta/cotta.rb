# Cotta module that contains all the classes used for file operations
# see link:files/README.html
module Cotta
  # Creates CottaFile repersenting physical file
  def self::file(path)
    FileFactory.file(path)
  end

  # Creates CottaDir representing physical directory
  def self::dir(path)
    FileFactory.dir(path)
  end

  # Creates CottaDir that is the parent of the path
  # This is typically used with __FILE__
  # e.g. dir = Cotta.parent_dir(__FILE__)
  def self.parent_dir(path)
    FileFactory.parent_dir(path)
  end

  # Returns the file facotry backed by physical system
  def self::physical
    FileFactory.physical
  end

  # Returns the file factory backed by in-memory system
  def self::in_memory
    FileFactory.in_memory
  end
end