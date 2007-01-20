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

require 'logger'
require 'sync'
require 'thread'

class Task
	def initialize(call, params, do_safe = false)
		@call = call
		if do_safe
			@params = []
			params.each do |x| 
				@params << x.clone
			end
		else 
			@params = params
		end
	end

	def invoke
		@call.call @params
	end

	attr_reader :call, :params
end


class TaskQueue < Queue
	#protected :shift 
	#protected :deq 
	#protected :pop 

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
			while not @do_quit do
				Thread.stop if @pause
				current = self.pop
				current.invoke
				count += 1
				Thread.pass if yield_every > 0 and (count % yield_every == 0)
			end
		end
		@the_thread.run
	end
	
	attr :pause
end
