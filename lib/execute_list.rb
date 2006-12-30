###########################################################################
#   Copyright (C) 2006 by Paul Betts                                      #
#   paul.betts@gmail.com                                                  #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
###########################################################################

# Ruby standard library
require 'logger'
require 'gettext'
require 'pathname'
require 'fileutils'

include GetText

class ExecuteList
	def begin(output_file); end
	def cp(src, dest); FileUtils.cp Pathname.new(from).realpath, dest; end
	def mv(src, dest); FileUtils.mv Pathname.new(from).realpath, dest; end
	def mkdirs(path); FileUtils.mkdir_p path; end
	def link(from, to); FileUtils.ln_s Pathname.new(from).realpath, to; end
	def finish; end
end

class ShellScriptList
	def begin(output_file)
		@o = File.open output_file, 'w'
		@o.puts '#!/bin/sh'
	end

	def cp(src, dest); @o.puts "cp -a #{src} #{dest}"; end
	def mv(src, dest); @o.puts "mv #{src} #{dest}"; end
	def mkdirs(path); @o.puts "mkdir -p #{path}"; end
	def link(from, to); @o.puts "ln -s #{from} #{to}"; end
	def finish; @o.close; end
end

class DebugList
	def begin(output_file); @o = STDOUT end
	def cp(src, dest); @o.puts "cp -a #{src} #{dest}"; end
	def mv(src, dest); @o.puts "mv #{src} #{dest}"; end
	def mkdirs(path); @o.puts "mkdir -p #{path}"; end
	def link(from, to); @o.puts "ln -s #{from} #{to}"; end
	def finish; end
end
