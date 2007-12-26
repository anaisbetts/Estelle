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

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")

# Ruby standard library
require 'rubygems'
require 'logger'
require 'gettext'
require 'pathname'
require 'singleton'

# Estelle 
require 'song'

include GetText

Allowed = ['wma']
class DummyTagger
	include Singleton

	def get_tags?(path)
		Allowed.include? Pathname.new(path).extname
	end

	def song_info(path)
		id = Object::object_id
		return (Song.new 'test' + id.to_s, 'testalbum' + (id % 13).to_s, 'testartist' + (id % 200).to_s)
	end
end

# This is here to test our loader
class Decoy
	def get_tags?(path)
		throw "Not a real tagger!"
	end
end

class CompletelyUnrelated
	def foo
		"bar"
	end
end
