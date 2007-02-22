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
require 'ButtonDialog.glade'
require 'config'

include GetText
include Gdk
include Gtk

class ButtonDesc
	def initialize(symbol, button, secondary)
		@symbol, @btn, @secondary = [symbol, button, secondary]
	end

	def ButtonDesc.new_custom(symbol, text, icon = nil, secondary = false)
		btn = Gtk::Button.new(text, true)
		btn.image = icon if icon
		ButtonDesc.new(symbol, btn, secondary)
	end

	def ButtonDesc.new_stock(stock_id, secondary = false)
		@btn = Gtk::Button.new stock_id
		ButtonDesc.new(stock_id, @btn, secondary)
	end 

	def add_to_buttonbox(dialog, box)
		@btn.signal_connect("clicked") { |*params| dialog.clicked = @symbol; Gtk.main_quit }
		box.pack_start(@btn, false, true, 6)
		box.set_child_secondary(@btn, @secondary)
	end

	attr_accessor :dialog
end

class ButtonDialog < ButtonDialogGenerated
	def initialize
		super(File.dirname(__FILE__), true, nil, Config::Package)
	end

	def prompt(primary_text, secondary_text, title, items, style = Gtk::ButtonBox::END)
		@clicked = nil
		@buttonbox.layout_style = style
		@glade["ButtonDialog"].title = title
		@prompt.markup = "<span size='xx-large'>#{primary_text}</span>\n\n#{secondary_text}"
		items.each { |btn| btn.add_to_buttonbox(self, @buttonbox) }
		@glade["ButtonDialog"].show_all;	Gtk.main

		@clicked
	end

	def on_dialog_delete_event(widget, arg0)
		Gtk.main_quit
	end

	attr_accessor :clicked
end
