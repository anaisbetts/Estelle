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

# Ruby standard library
require 'logger'
require 'gettext'
require 'pathname'

# Estelle 
require 'platform'
include GetText

module FormatParser
	def create_format_string(format_string)
		# Find the tags used in the string
		s = format_string.clone
		tags_used = []
		while /(<\S*?>)+[^<]*/.match s do
			tags_used << $1[1..$1.length-2].to_sym
			s.sub! /(<\S*?>)+[^<]*/, ''
		end

		# Sub them in
		result = format_string.clone
		tags_used.each do |x|
			result.gsub x, '%s'
		end
		[result, tags_used]
	end
end
