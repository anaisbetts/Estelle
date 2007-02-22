$: << '..'

require 'buttondialog'

bd = ButtonDialog.new()
ret = bd.prompt( "Select an item", "An Item must be selected n000000000000000000000000000b!", "A title"
		[ ButtonDesc.new_stock(Gtk::Stock::CANCEL),
		  ButtonDesc.new_stock(Gtk::Stock::OK),
		  ButtonDesc.new_stock(Gtk::Stock::HELP, true)] )
p (ret ? ret : 'Null!')
