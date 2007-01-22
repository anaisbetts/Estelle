#!/usr/bin/env ruby
#
# ruby-glade-create-template
#
# Create a ruby-glade template .rb file from a .glade file.
#
# Usage: ruby ruby-glade-create-template yourgladefile.glade > file.rb
#
# $Id: ruby-glade-create-template,v 1.14 2006/06/17 14:14:54 mutoh Exp $
#
# Copyright (c) 2002-2005 Masao Mutoh <mutoh@highway.ne.jp>
# Additions by Paul Betts
#

require 'libglade2'
require 'rexml/document'

LG_VERSION = %Q[$Revision: 1.14 $].scan(/\d/).join(".")

unless ARGV.size == 1
	puts "ruby-glade-create-template #{LG_VERSION}"
	puts "\nUsage: ruby ruby-glade-create-template.rb yourgladefile.glade > file.rb\n\n"
	exit 1
end

path = ARGV[0]

#
# Support GNOME ?
#
type_gnome = false
doc = REXML::Document.new(IO.read(path))
doc.elements.each("//requires") do |e|
	if e.attributes["lib"] == "gnome"
		type_gnome = true
		begin
			require 'gnome2'
		rescue LoadError
			puts "The .glade requires Ruby/GNOME2, but it is not available on your system."
			exit 1
		end
	end
end

DefaultNameRegex = /^[a-z]+[0-9]+$/
def is_default_name(str)
	return false if str.downcase != str
	return DefaultNameRegex.match(str)
end

#
# Analyse .glade file.
#
filename = File.basename(path, ".*")

# Create class name from the filename.
tmp = filename.split(/[_-]/).collect do |item| 
	if item =~ /[A-Z]/
		item
	else
		item.capitalize 
	end
end
classname = tmp.join("") + "Generated"

if type_gnome
	Gnome::Program.new("ruby-glade-create-template", LG_VERSION)
end

# Get signals.
GladeXML.set_custom_widget_handler(false)
glade = GladeXML.new(path)
signals = {}
glade.signal_autoconnect_full{|source, target, signal_name, handler, data, after|
	signals[glade.canonical_handler(handler)] = source.class.signal(signal_name)
}

# Get Menu for GnomeApp and Tooltips.
gnomeapp = nil
uiinfos = []
tooltips = []
objects = []
doc.elements.each("//widget") do |e|
	if e.attributes["class"] == "GnomeApp"
		gnomeapp = e.attributes["id"]
	elsif /Separator/ =~ e.attributes["class"]
		#Do nothing
		#    elsif /ImageMenuItem/ =~ e.attributes["class"]
	elsif e.elements["property[@name='stock_item']"]
		e.elements.each("property[@name='stock_item']"){|v|
			if v.attributes["name"] == "stock_item"
				if /GNOMEUIINFO_MENU_(.*)_ITEM/ =~ v.text
					if $1 == "EXIT"
						uiinfos << [%Q!Gnome::UIInfo::menu_quit_item(callback_dummy, nil)!, e.attributes['id']]
					elsif $1 == "NEW"
						label = ""
						e.elements.each("property[@name='label']") do |v|
						label = "'#{v.text}'"
						end
					uiinfos << [%Q!Gnome::UIInfo::menu_new_item(#{label}, nil, callback_dummy, nil)!, e.attributes['id']]
					else
						tooltip = "nil"
						e.elements.each("property[@name='tooltip']") do |v|
							tooltip = "'#{v.text}'"
						end
						uiinfos << [%Q!Gnome::UIInfo::menu_#{$1.downcase}_item(callback_dummy, #{tooltip})!, e.attributes['id']]
					end
				end
			end
		}
	elsif /MenuItem/ =~ e.attributes["class"]
		label = "nil"
		tooltip = nil
		e.elements.each("property[@name='tooltip']") do |v|
			tooltip = "'#{v.text}'"
		end
		if tooltip
			uiinfos << [%Q!Gnome::UIInfo.item_none(#{label}, #{tooltip}, callback_dummy)!, e.attributes['id'], true]
		end
	elsif /Tool|Action/ =~ e.attributes["class"]
		tooltip = nil
		e.elements.each("property[@name='tooltip']") do |v|
			tooltip = "'#{v.text}'"
		end
		if tooltip
			tooltips << %Q!@glade['#{e.attributes['id']}'].set_tooltip(@tooltip, _(#{tooltip}))!
		end
	end

	unless is_default_name(e.attributes["id"]) or e.attributes["id"] == filename
		objects << e.attributes["id"]
	end
end

additional_methods = ""
# Create an additional method for creating additional menu hints of GnomeApp.
additional_method_body = ""
if gnomeapp and uiinfos.size > 0
	additional_method_body << "\n  # Creates menu hints.\n"
	additional_method_body << "  def create_uiinfo_menus(name)\n"
	additional_method_body << "    app = @glade['#{gnomeapp}']\n"
	additional_method_body << "    tips = @glade.get_tooltips(app.toplevel)\n"
	additional_method_body << "    callback_dummy = Proc.new{} #Dummy \n"
	additional_method_body << "    uiinfos = [\n"
	uiinfos.each do |info|
		additional_method_body << "      #{info[0]},\n"
	end
	additional_method_body << "    ]\n"
	uiinfos.each_with_index do |info, i|
		additional_method_body << "    uiinfos[#{i}][9] = @glade['#{info[1]}']\n"
		additional_method_body << "    tips.set_tip(uiinfos[#{i}][9], nil, nil)\n" if info[2]
	end
	additional_method_body << "    app.install_menu_hints(uiinfos)\n"
	additional_method_body << "  end"
	additional_methods << "\n    create_uiinfo_menus(domain)"
end

# Create an additional method for creating tooltips.
if tooltips.size > 0
	additional_method_body << "\n  # Creates tooltips.\n"
	additional_method_body << "  def create_tooltips\n"
	additional_method_body << "    @tooltip = Gtk::Tooltips.new\n"
	tooltips.each do |v|
		additional_method_body << "    #{v}\n"
	end
	additional_method_body << "  end"
	additional_methods << "\n    create_tooltips"
end

# Creates handler methods
handler_methods = ""
if signals.size > 0
	signals.each do |handler, signal|
		args = "widget"
		(0...signal.param_types.size).each do |i|
			args << ", arg#{i}"
		end
		handler_methods << "\n  def #{handler}(#{args})\n"
		handler_methods << "    puts \"#{handler}() is not implemented yet.\"\n"
		handler_methods << "  end"
	end
end

# Creates widget instance variables
widget_defs = ""
objects.each do |obj|
	widget_defs << "\n    @#{obj} = @glade.get_widget(\"#{obj}\")"
end
widget_defs << "\n"

#
# Print template.
#
puts <<CLASS_DEF
#!/usr/bin/env ruby
#
# This file is gererated by ruby-glade-create-template #{LG_VERSION}.
#
require 'libglade2'

class #{classname}
  include GetText

  attr :glade
  #{additional_method_body}
  def initialize(path_or_data, add_file_name = true, root = nil, domain = nil, localedir = nil, flag = GladeXML::FILE)
    bindtextdomain(domain, localedir, nil, "UTF-8")
    pd = path_or_data
    pd = File.join(pd, "#{filename}.glade") if add_file_name
    @glade = GladeXML.new(pd, root, domain, localedir, flag) {|handler| method(handler)}
    #{additional_methods}
    #{widget_defs}
  end
  #{handler_methods}
end
CLASS_DEF

puts <<MAIN1

# Main program
if __FILE__ == $0
  # Set values as your own application. 
  PROG_PATH = "#{File.basename path}"
  PROG_NAME = "YOUR_APPLICATION_NAME"
MAIN1

# Bottom mehotds
if type_gnome
	puts <<FOOTER_GNOME
  PROG_VERSION = "YOUR_APPLICATION_VERSION"
  Gnome::Program.new(PROG_NAME, PROG_VERSION)
FOOTER_GNOME
end
puts <<FOOTER
  #{classname}.new(PROG_PATH, false, nil, PROG_NAME)
  Gtk.main
end
FOOTER

if glade.custom_creation_methods.size > 0
	puts "#You may need to implement some custom creation methods which return new widget."
	glade.custom_creation_methods.each do |v|
		puts "#" + v
	end
end

