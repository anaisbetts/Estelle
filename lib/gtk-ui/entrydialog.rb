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
require 'EntryDialog.glade'
require 'config'

include GetText
include Gdk
include Gtk

class EntryDialog < EntryDialogGenerated
	def initialize
		super(File.dirname(__FILE__), true, nil, Config::Package)
	end

	def prompt_text(title, 
			primary_text, 
			secondary_text, 
			initial_entry = '', 
			validator = lambda {|x| true })
		@glade["EntryDialog"].title = title
		@validator = validator
		@prompt.markup = "<span size='xx-large'>#{primary_text}</span>\n\n#{secondary_text}"
		@glade["EntryDialog"].show_all; Gtk.main

		@text
	end

	def on_ok_released(widget); @text = @entry.text; Gtk.main_quit; end
	def on_cancel_released(widget); @text = nil; Gtk.main_quit; end
	def on_dialog_delete_event(widget, arg0); on_cancel_released(widget); end

	def on_entry_key_release_event(widget, key_event)
		on_ok_released(@ok) if key_event.keyval == Keyval::GDK_Return and @ok.sensitive?
	end

	def on_entry_changed(widget)
		@ok.sensitive = @validator.call(@entry.text)
	end
end
