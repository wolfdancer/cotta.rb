dir = File.dirname(__FILE__)

require 'rubygems'
# Gem::manage_gems
require 'rake'
require dir + '/lib/cotta'

root = Cotta::FileFactory.parent_dir(__FILE__)
VERSION_NUMBER = root.file('lib/cotta/version').load

SPEC = Gem::Specification.new do |spec|
  spec.name = 'cotta'
  spec.version = VERSION_NUMBER
  spec.author = 'Shane Duan'
  spec.email = 'cotta@googlegroups.com'
  spec.homepage = 'http://cotta.rubyforge.org/'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'A project for a better file operation API in Ruby'
  spec.files = FileList["{docs,lib,test}/**/*"].exclude("rdoc").to_a
  spec.require_path = 'lib'
  spec.has_rdoc = true
  spec.rubyforge_project = 'cotta'
  spec.extra_rdoc_files = ["README"]
  spec.description = 'a lightweight, simple and sensible API to file operation and testing'
end
