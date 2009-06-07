dir = File.dirname(__FILE__)

require 'rubygems'
# Gem::manage_gems
require 'rake'
require dir + '/lib/cotta'

root = Cotta::Cotta.parent_of(__FILE__)
VERSION_NUMBER = root.file('lib/cotta/version').load

SPEC = Gem::Specification.new do |spec|
  spec.name = 'Cotta'
  spec.version = VERSION_NUMBER
  spec.author = 'Shane Duan'
  spec.email = 'cotta@googlegroups.com'
  spec.homepage = 'http://cotta.rubyforge.org/'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'A project for a better file operation API in Ruby'
  spec.files = FileList["{docs,lib,test}/**/*"].exclude("rdoc").to_a
  spec.require_path = 'lib'
  spec.autorequire = 'cotta'
  spec.has_rdoc = true
  spec.rubyforge_project = 'cotta'
  spec.extra_rdoc_files = ["README"]
end