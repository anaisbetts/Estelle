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
require 'singleton'
require 'MainWindow.glade'
require 'config'
require 'thread'
require 'utility'
require 'song'

include GetText
include Gtk
include Gdk

class SongWrapper < GLib::Object
	def initialize(song)
		@obj = song
	end

	attr :obj
end

class MainWindow < MainWindowGenerated
	include Singleton

	Icon = 0
	Text = 1
	SONG = 2
	def initialize
		super(File.dirname(__FILE__), true, nil, Config::Package)

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

		# Set up the tree view
		@fv_store = TreeStore.new( Pixbuf, String, SongWrapper )
		@file_view.model = @fv_store
		col = TreeViewColumn.new("Name")
		col.pack_start( (cp = CellRendererPixbuf.new), false);	col.add_attribute(cp, :pixbuf, Icon)
		col.pack_start( (ct = CellRendererText.new), true );	col.add_attribute(ct, :text, Text)
		@file_view.append_column(col)
	end

	def show_dialog
		update_dialog
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

		@ok.sensitive = @task_queue.empty?
		@cancel_action.sensitive = (not @task_queue.empty?)
		@filechooser_source.sensitive = (not @in_file_operation)
	end

	def update_track_info
		markup = "<span size=\"xx-large\">%s</span>" % _("Track Information")
		unless @cur_track
			markup += _("\n<i>No Track Selected</i>")
			return
		else
			# TODO: Figure out the track info
		end
		@track_information.markup = markup
	end

	def update_file_tree
		# TODO: Take the MusicLibrary and rebuild it as a tree
		unless @music_library
			@fv_store.clear
			return
		end
	end

	def update_progress_bar(text = '', fraction = 0)
		@progress_bar.text = text
		@progress_bar.fraction = fraction 
	end


	#####################
	## Event Handlers
	#####################
	public
	
	def window_delete_event(widget, arg0); Gtk.main_quit; end

	def on_filechooser_source_selection_changed(widget)
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
