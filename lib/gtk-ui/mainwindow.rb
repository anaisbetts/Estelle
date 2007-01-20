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
require 'gettext'
require 'MainWindow.glade'
require 'config'
require 'thread'
require 'utility'

include GetText

class MainWindow < MainWindowGenerated
	def initialize
		super(File.dirname(__FILE__), true, nil, Config::Package)
	end

	def show_dialog
		update_dialog

		# Set up a framework to process these long-running tasks while
		# still keeping the UI available. Basically we create a
		# "Task Queue", a queue that also has a thread that dequeues
		# things to do and executes them. It also enqueues UI-related 
		# tasks into another thread called update_queue, which prevents
		# GTK+ threading issues. A timeout function is created to process
		# the update_queue
		@update_queue = Queue.new 
		@task_queue = TaskQueue.new

		# Process UI changes
		@timeout_handle = Gtk.timeout_add(100) do
			i = 10
			until @update_queue.empty? or i > 5
				@update_queue.pop.invoke
			end
		end

		@glade["MainWindow"].show_all; Gtk.main
	end

	#####################
	## Utility functions
	#####################
	private

	def update_dialog
		update_track_info
		update_file_tree
		update_progress_bar
	end

	def update_track_info
	end

	def update_file_tree
	end

	def update_progress_bar
	end


	#####################
	## Event Handlers
	#####################
	public
	
	def window_delete_event(widget, arg0); Gtk.main_quit; end

	def on_filechooser_source_selection_changed(widget)
		puts "on_filechooser_source_selection_changed() is not implemented yet."
	end

	def on_ok_released(widget)
		puts "on_ok_released() is not implemented yet."
	end

	HPanedBuffer = 128
	def on_hpaned1_size_request(widget, arg0)
		width = @glade["MainWindow"].size[0]
		widget.position = HPanedBuffer if widget.position < HPanedBuffer 
		widget.position = width - HPanedBuffer if width - widget.position < HPanedBuffer 
	end

	def on_file_view_move_cursor(widget, arg0, arg1)
		puts "on_file_view_move_cursor() is not implemented yet."
	end

	def on_soundtrack_format_button_released(widget)
		puts "on_soundtrack_format_button_released() is not implemented yet."
	end

	def on_show_all_toggled(widget)
		puts "on_show_all_toggled() is not implemented yet."
	end

	def window_delete_event(widget, arg0)
		Gtk.timeout_remove @timeout_handle
		Gtk.main_quit
	end

	def on_music_format_button_released(widget)
		puts "on_music_format_button_released() is not implemented yet."
	end
end
