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
$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")

# Ruby standard library
require 'logger'
require 'gettext'
require 'pathname'
require 'singleton'

# Estelle 
require 'song'
require 'taglib'

include GetText

class TagLibTagger < Logger::Application
	include Singleton

	def initialize
		super(self.class.to_s) 
		self.level = $logging_level 
	end

	def get_tags?(path)
		@allowed ||= Taglib::FileRef.defaultFileExtensions.toString.to_s.split ' '
		return @allowed.include?(Pathname.new(path).extname.slice(1,10))
	end

	# Estelle::Song name => Taglib::Tag name
	TaglibMapping = { :album => 'album', :artist => 'artist', :genre => 'genre',
			  :title => 'title', :track => 'track', :year => 'year' }
	ApMapping = { :bitrate => 'bitrate', :channels => 'channels', 
		      :length => 'length', :samplerate => 'sampleRate' }

	def song_info(path)
		#log DEBUG, "Loading info for #{path.to_s}"
		f = Taglib::FileRef.new(path.to_s)
		if f.isNull
			#log DEBUG, "Couldn't read #{path.to_s}"
			return nil
		end

		t = f.tag; s = Song.new; a = f.audioProperties
		#log DEBUG, "Artist is #{t.artist.to_s}"
		s[:path] = path
		TaglibMapping.keys.each do |key|
			s[key] = (t.send(TaglibMapping[key]).to_s)
		end
		ApMapping.keys.each do |key|
			s[key] = (a.send(ApMapping[key]).to_s)
		end

		#log DEBUG, s.to_s; 
		s
	end
end
