$:.unshift File.dirname(__FILE__)

require 'rubygems'                                                                                                                             
require 'rake/gempackagetask'                                                                                                                  
require 'rake/contrib/rubyforgepublisher'                                                                                                      
require 'rake/clean'
require 'rake/rdoctask'                                                                                                                        
require 'rake/testtask'
require 'spec'

require 'lib/platform'

root_dir = File.dirname(__FILE__)
load File.join(root_dir, 'build', 'expand.rake')

### Constants

PKG_NAME = "estelle"
PKG_VERSION   = "0.1"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
]

# Fixed up clean section to pick up extensions
CLEAN = FileList["**/*~", "**/*.bak", "**/core", 'ext/taglib/**/*.o', 'ext/**/*.dll', 'ext/**/*.so', 'ext/**/*.dylib']
CLOBBER = FileList['ext/**/Makefile', 'ext/**/CMakeCache.txt']


########################
## Tasks
########################

to_expand = FileList.new '**/*.in'

desc "Process .in files"
task :expandify => to_expand do |f|
	to_expand.each() do |ex|
#		expand_file(ex, ex.gsub(/\.in$/, ''))
	end
end

# Taglib
desc "Build the Taglib library"
task :taglib do |t|
#	sh "cd ext/taglib && cmake ."
#	sh "cd ext/taglib && make"
end

desc "Run unit tests"
Rake::TestTask.new("test") do |t|
	t.pattern = 'tests/*.rb'
	t.verbose = true
	t.warning = true
end

# Default Action
task :default => [
	:taglib,
	:updatepo,
	:expandify,
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
