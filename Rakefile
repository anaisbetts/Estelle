$:.unshift File.dirname(__FILE__)

require 'rubygems'                                                                                                                             
require 'rake/gempackagetask'                                                                                                                  
require 'rake/contrib/rubyforgepublisher'                                                                                                      
require 'rake/clean'
require 'rake/rdoctask'                                                                                                                        
require 'rake/testtask'
require 'spec'

# Load other build files
Dir.glob("build/*.rake").each {|x| load x}

### Constants

PKG_NAME = "estelle"
PKG_VERSION   = "0.1"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

# Fixed up clean section to pick up extensions
CLEAN = FileList["**/*~", "**/*.bak", "**/core", 'ext/taglib/**/*.o', 'ext/**/*.dll', 'ext/**/*.so', 'ext/**/*.dylib', 'bin/*', 'data/*']
CLOBBER = FileList['ext/**/Makefile', 'ext/**/CMakeCache.txt']


########################
## Tasks
########################

desc "Process .in files"
task :expandify do |f|
	Dir.glob("{lib,bin}/**/*.in").each() do |ex|
		expand_file(ex, ex.gsub(/\.in$/, ''))
	end
end

# Taglib
desc "Build the Taglib library"
task :taglib do |t|
	sh "cd ext/taglib && cmake ."
	sh "cd ext/taglib && make"
	sh "mkdir -p bin"
	Dir.glob("ext/**/*.{dll,so,dylib}").each {|x| sh "cp #{x} bin/"}
end

desc "Update missing tests"
task :buildtests do |t|
	Dir.glob("{lib}/**/*.rb").each {|x| sh "./build_unit_test #{x}"}
end

desc "Run unit tests"
Rake::TestTask.new("test") do |t|
	t.pattern = 'test/**/*.rb'
	t.verbose = true
	t.warning = true
end

desc "Run code coverage"
task :coverage do |t|
	sh "rcov -xrefs " + Dir.glob("test/**/*.rb").join(' ') + " 2>/dev/null"
end

# Default Action
task :default => [
	:taglib,
	:updatepo,
	:makemo,
	:expandify,
]

task :alltests => [
	:test,
	:coverage
]


#######################
## Gettext section
#######################

require 'gettext/utils'

desc "Create mo-files for l10n"
task :makemo do 
	GetText.create_mofiles(true, "./po", "./data/locale")
end

desc "Update pot/po files to match new version." 
task :updatepo do
	GetText.update_pofiles(PKG_NAME,
			       Dir.glob("{app,lib}/**/*.{rb,rhtml}"),
			       "#{PKG_NAME} #{PKG_VERSION}")
end
