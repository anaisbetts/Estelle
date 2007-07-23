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
require 'platform'

include GetText

class ExecuteList
	def begin(output_file); end
	def cp(src, dest, song); FileUtils.cp Pathname.new(from).realpath, dest; end
	def mv(src, dest, song); FileUtils.mv Pathname.new(from).realpath, dest; end
	def link(from, to, song); FileUtils.ln_s Pathname.new(from).realpath, to; end
	def mkdirs(path); FileUtils.mkdir_p path; end
	def finish; end
end

class ShellScriptList
	def begin(output_file)
		@o = File.open output_file, 'w'
		@o.puts '#!/bin/sh'
	end

	def cp(src, dest, song); @o.puts "cp -a #{src} #{dest}"; end
	def mv(src, dest, song); @o.puts "mv #{src} #{dest}"; end
	def link(from, to, song); @o.puts "ln -s #{from} #{to}"; end
	def mkdirs(path); @o.puts "mkdir -p #{path}"; end
	def finish; @o.close; end
end

class DebugList
	def begin(output_file); @o = STDOUT end
	def cp(src, dest, song); @o.puts "cp -a #{src} #{dest}"; end
	def mv(src, dest, song); @o.puts "mv #{src} #{dest}"; end
	def link(from, to, song); @o.puts "ln -s #{from} #{to}"; end
	def mkdirs(path); @o.puts "mkdir -p #{path}"; end
	def finish; end
end

class TreeModelBuilderList
	private

	public
	def begin(treemodel)
		@tm = treemodel
		@cache = {}
	end

	def cp(src, dest, song)
		path, file = Pathname.new(dest).split
		parent = @cache[path]
		return unless parent
		iter = @tm.insert(parent, 0)
		iter[MainWindow::Song] = SongWrapper.new(song)
		iter[MainWindow::Text] = file
	end

	alias mv cp
	alias link cp

	def mkdirs(path)
		return if @cache[path]

		items = path.to_s.split(/[\\\/]/).to_a
		items[0] = '/' unless Platform.os() == :windows

		# Find the last existing one
		to_start = (Platform.os() == :windows ? (lastitem = items.shift()) : '/')
		buf = Pathname.new(to_start)
		p "At start, buf = #{buf}"
		while(items.size > 0 and @cache[buf.to_s])
			nextitem = buf.clone.join(items[0])
			print "nextitem = #{nextitem}\n"
			break if @cache[nextitem.to_s] == nil
			items.shift;	buf = nextitem
		end
		
		while(items.size > 0)
			s = items.shift
			newbuf = buf.join(s)
			iter = @tm.insert(@cache[buf.to_s],0)
			iter[MainWindow::Text] = s
			@cache[newbuf.to_s] = iter
			buf = newbuf
		end
	end

	def finish; @cache.clear; end
end

