gem('rake')

require 'rubygems'
require 'rubygems/gem_runner'
# Gem::manage_gems
require 'rake'
require 'spec/rake/spectask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rcov/rcovtask'
require 'specs'

root_dir = Cotta::FileFactory.parent_dir(__FILE__)
build_dir = root_dir.dir('build')
rdoc_dir = build_dir.dir('rdoc')
rcov_dir = build_dir.dir('rcov')
rspec_dir = build_dir.dir('rspec')

task :init do
  rcov_dir.mkdirs
  rspec_dir.mkdirs
end

#desc "Run all specifications"
Spec::Rake::SpecTask.new(:coverage) do |t|
  t.spec_files = FileList['test/**/*_spec.rb']
  t.rcov = true
  t.rcov_dir = rcov_dir.path
  outputfile = rspec_dir.file('index.html').path
  t.spec_opts = ["--format", "html:#{outputfile}", "--diff"]
  t.fail_on_error = false
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.main = "README"
  rdoc.rdoc_files.include('README', "lib/cotta/*.rb")
  rdoc.options << "--all"
  rdoc.rdoc_dir = rdoc_dir.to_s
end

task :default => [:coverage, :rdoc, :package]
task :coverage => [:init]
task :local_install => [:package]

task :default do
  rcov_dir.copy_to rdoc_dir.dir('rcov')
  rspec_dir.copy_to rdoc_dir.dir('rspec')
end

task :package do
  require 'rubygems'
  require 'rubygems/gem_runner'
  Gem::Builder.new(SPEC).build
end

task :local_install do
  gem_file = SPEC.full_name + ".gem"
  puts "Insalling #{gem_file}..."
  Gem::Installer.new(gem_file).install
end

task :publish_site do
  output_dir = rdoc_dir
  raise 'output dir needs to be called the same as the project name for one copy action to work' unless output_dir.name == 'cotta'
  # puts PscpDriver.new("wolfdancer@cotta.rubyforge.org").copy(output_dir.path, '/var/www/gforge-projects')
end
