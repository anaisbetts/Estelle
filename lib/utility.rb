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

$:.unshift File.join(File.dirname(__FILE__))

require 'rubygems'
require 'logger'
require 'sync'
require 'thread'

# Estelle
require 'song'
require 'settings'

class Task
	def initialize(call, params, do_safe = false)
		@call = call
		if do_safe and params
			@params = params.collect { |x| x.clone }
		else 
			@params = (params ? params : [])
		end
	end

	def invoke
		@call.call(*@params) if @call
	end

	attr_reader :call, :params
end


class TaskQueue < Queue
	protected :shift 
	protected :deq 
	protected :pop 

	public
	def initialize(yield_every = 0)
		super()
		@do_quit = false
		@pause = false
		@the_thread = nil 
		@yield_every = yield_every
	end

	def start     
		if @the_thread 
			@pause = false
			@the_thread.run if @the_thread.stop?
			return
		end

		# Start the thread
		@the_thread = Thread.new(@yield_every) do |yield_every|
			count = 0
			puts "Starting loop"
			while not @do_quit do
				Thread.stop if @pause
				puts "Running: size = #{size()}"
				self.pop.invoke
				count += 1
				Thread.pass if yield_every > 0 and (count % yield_every == 0)
			end
		end
		@the_thread.run
	end

	def clear_and_halt()
		clear
		return unless @the_thread
		@the_thread.kill
		@the_thread = nil
	end
	
	attr :pause
end


##############################
# Miscellaneous Functions
##############################

ToEscape = [
	[ '\\', "\\\\" ],
	[ '"', "\"" ],
	[ '\'', "'" ],
	[ ',', "\\," ],
	[ '\'', "\\'" ],
	[ '-', "\\-" ],
	[ '(', "\\(" ],
	[ ')', "\\)" ],
	[ '&', "\\&" ],
	[ ' ', "\\ " ],
]
def escaped_path(path)
	ret = path.clone.to_s
	ToEscape.each { |x| ret.gsub!(x[0], x[1]) } ; ret
end

def filelist_from_root(path)
	list = []
	d = Pathname.new path
	d.find { |x| list << x.to_s }

	list
end

def load_settings(library)
	# Load our settings
	@settings = EstelleSettings.load(Platform.settings_file_path) || EstelleSettings.new
	Song.sub_table = @settings.tagsubst_table
	library.is_soundtrack = @settings.soundtrack_table
end
