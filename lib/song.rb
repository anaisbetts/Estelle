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

# Ruby standard library
require 'rubygems'
require 'logger'
require 'gettext'
require 'pathname'
require 'digest/md5'

include GetText

FeaturingList = ['Featuring', 'Feat.', 'featuring', 'feat.', 'FEATURING', 'FEAT.']

class Song 
	def initialize(hash = {})
		@data = hash.clone
	end

	def get_canonical_artist
		return nil unless @data[:artist]

		# First, replace everything in the 'Featuring' list with a comma
		s = @data[:artist].clone 
		FeaturingList.each { |x| s.sub!(x, ',') }

		# Then, split on any sort of punctuation
		artists = s.split(/[;,:\|-]/)
		artists.delete_if { |x| x.chomp.empty? }
		@data[:canonical_artist] = (artists.sort.join ',')
	end

	def [](key)
		case key
		when :path
			@data[key].to_s
		when :canonical_artist
			return @data[key] if @data.has_key? key
			@data[key] = get_canonical_artist
		else 
			@data[key]
		end
	end

	def []=(key, val)
		case key
		when :ext
			# This is a generated property - don't let anyone set it
			nil
		when :path
			@data[key] = Pathname.new val
			@data[:ext] = @data[key].extname[1..25]
		when :length
			seconds = @data[key] = val.to_i
			@data[:hours] = (seconds / 3600).to_s; seconds %= 3600
			@data[:minutes] = (seconds / 60).to_s; seconds %= 60
			@data[:seconds] = seconds.to_s
		when :seconds, :minutes, :hours
			@data[key] = val
			h = @data[:hours].to_i; m = @data[:minutes].to_i; s = @data[:seconds].to_i
			@data[:length] = (h*3600+m*60+s).to_s
		when :artist
			@data[key] = super_chomp(val)
			@data.delete :canonical_artist if @data.has_key? :canonical_artist
		else 
			@data[key] = super_chomp(val)
		end
	end

	def checked_tag(key, invalid_chars, checking_proc)
		@@sub_table ||= {}
		data = @data[key] || "<#{key}>"		# Write the original key back

		# Switch out the data with a replacement if we've got one
		data = @@sub_table[data] || data
		return data unless data =~ invalid_chars

		# Prompt the user for a replacement
		default = data.gsub(invalid_chars, ' ')
		repl = data
		puts checking_proc
		while repl =~ invalid_chars
			repl = checking_proc.call(repl.clone, invalid_chars, default)
			repl = default if repl.chomp.empty?
		end
		@@sub_table[data] = repl;
		repl = _("(Unknown)") if repl.chomp.empty? 
		repl
	end

	def Song.sub_table; @@sub_table end
	def Song.sub_table=(val); @@sub_table=val end
	
	def to_hash; @data.clone end
	def to_s; @data.to_s end
end
