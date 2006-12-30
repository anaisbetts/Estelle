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
require 'execute_list'

include GetText

DefaultTaggerPath = File.join(File.dirname(__FILE__), 'taggers')
class MusicLibrary < Logger::Application
	protected	
	@taggers = nil
	@tag_info = nil
	@is_soundtrack = nil
	@album_info = nil

	public 
	def initialize
		super(self.class.to_s()) 
		self.level = $logging_level
	end

	def load(files, progress_rate = 0.05)
		load_taggers(DefaultTaggerPath) unless @taggers
		return unless @taggers

		@tag_info = {}
		log INFO, "Processing #{files.size} files..."
		count = 0
		yield_every = (files.size * progress_rate).to_i
		files.each do |current|
			count += 1
			#log DEBUG, 'Reading %s..' % current

			# Check to see if we can load this file
			loader = nil
			@taggers.each { |x| break if (loader = x).get_tags? current }
			next unless loader

			yield (count.to_f / files.size) if block_given? and (count % yield_every) == 0

			if (@tag_info[current] = loader.song_info(current))
				@tag_info[current][:path] = current
				next
			end

			# Can't be loaded, delete it and move on
			@tag_info.delete current
		end 

		log INFO, "Loaded #{@tag_info.size} files"
		log DEBUG, "Exiting load"
	end

	def find_soundtracks
		@is_soundtrack = {}
		log DEBUG, "Entering find_soundtracks"

		build_tables unless @album_info
		@album_info.keys.each do |curname|
			artists = {}
			current = @album_info[curname]

			current.each { |track| artists[track[:canonical_artist]] ||= 0; artists[track[:canonical_artist]] += 1; }
			histogram = artists.sort { |a,b| a[1] <=> b[1] }	# Sort by value
			#log DEBUG, "#{curname} - #{histogram.size} artists, leader has #{histogram[0][1]}"
			next if histogram[0][1] > 0.75*histogram.size or histogram.size < 3

			# Call out the handler 
			log DEBUG, "#{curname} may be a soundtrack; #{histogram.size} artists, leader has #{histogram[0][1]}"
			@is_soundtrack[curname] = true if yield(curname) 
		end

		log DEBUG, "Exiting find_soundtracks"
	end

	InvalidChars = /[:;\/<>]/
	InvalidCharsString = ':;\/<>'
	def create_action_list(target_root, musicformat, soundtrackformat)
		log DEBUG, "Creating action list"
		music_fstr,music_tags = create_format_string(musicformat)
		sndtrk_fstr,sndtrk_tags = create_format_string(soundtrackformat)
		
		# Iterate through all our files and create the list
		list = []
		@tag_info.values.each do |current|
			if @is_soundtrack[ current[:album] ] != true
				data = music_tags.collect do |x| 
					current.checked_tag (x, InvalidChars, lambda { |y,z| yield y,InvalidCharsString })
				end
				dest = File.join(target_root, 
						 music_fstr % data)
			else
				data = sndtrk_tags.collect do |x| 
					current.checked_tag (x, InvalidChars, lambda { |y,z| yield y,InvalidCharsString })
				end
				dest = File.join(target_root, 
						 sndtrk_fstr % data)
			end
			list << [ current[:path], dest ]
		end
		list
	end

	def execute_action_list(list, action, execute_class = DebugList, output_file = nil)
		do_it = execute_class.new
		do_it.begin output_file

		list.each do |x| 
			path = Pathname.new x[1]
			do_it.mkdirs path.dirname

			begin
				case action
				when :copy
					 do_it.cp x[0], x[1]
				when :move
					 do_it.mv x[0], x[1] 
				when :symlink
					 do_it.link x[0], x[1] 
				end
			rescue
				log ERROR, _("Failure processing %s") % x[0]
				next
			end
		end

		do_it.finish
	end

	def load_taggers(*paths)
		# Load the defaults, then the ones specified in the param
		paths.each do |x|
			log DEBUG, "Trying to load #{x}"
			Pathname.new(x).each_entry { |y| require File.join(x,y) if y.extname == '.rb' } 
		end

		# Now reflect through the objects and find ones that match
		@taggers = []
		tagger_classes = ObjectSpace.each_object(Class) do |x|
			pm = x.public_instance_methods(true)
			next unless pm.include? 'get_tags?' and pm.include? 'song_info'
			@taggers << x.instance
		end
		log DEBUG, "Loaded #{@taggers.size} taggers"
		@taggers = nil unless @taggers.size > 0
	end

	private

	def build_tables
		@album_info = {}
		@tag_info.values.each do |current|
			album = current[:album]
			@album_info[album] ||= []
			@album_info[album] << current
		end 
	end

	First_Tag = /(<\S*?>)+[^<]*/
	def create_format_string(format_string)
		# Find the tags used in the string
		s = format_string.downcase
		tags_used = []
		while First_Tag.match s do
			tags_used << $1
			s.sub! First_Tag, ''
		end

		# Sub them in
		result = format_string.downcase
		tags_used.each do |x|
			result.gsub! x, '%s'
		end
		ret = [result, tags_used.collect {|x| x[1..x.length-2].chomp.to_sym } ]
		log DEBUG, "fs = #{ret[0]}, tags = #{ret[1]}"; 	ret
	end
end
