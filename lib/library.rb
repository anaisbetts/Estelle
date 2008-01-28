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
require 'zlib'

# Estelle 
require 'platform'
require 'execute_list'
require 'song'

include GetText

$logging_level ||= Logger::ERROR

DefaultTaggerPath = File.join(File.dirname(__FILE__), 'taggers')
class Library < Logger::Application

	public 
	attr_writer :is_soundtrack
	attr_reader :taggers

	def initialize
		super(self.class.to_s()) 
		self.level = $logging_level

		@taggers = nil
		@tag_info = nil
		@album_info = nil
		@md5_index = nil
	end

	def clear
		@tag_info = nil
		@album_info = nil
	end

	def empty?; (not @tag_info) or @tag_info.empty?; end

	def size; (@tag_info ? @tag_info.size : 0); end

	def load(files, progress_rate = 0.05)
		load_taggers(DefaultTaggerPath) unless @taggers
		return unless @taggers

		load_cache

		@tag_info = {}
		log INFO, "Processing #{files.size} files..."
		count = 0
		yield_every = (files.length * progress_rate).to_i
		yield_every = 1 if (yield_every == 0)
		files.each do |current|
			count += 1
			yield(count.to_f / files.length) if (block_given? and (count % yield_every) == 0)
			#log DEBUG, 'Reading %s..' % current
			
			# First, see if we've already scanned this file before (save some time
			# and only read the first 256K)
			begin	
				md5sum = Digest::MD5.hexdigest(File.open(current, 'r') {|x| x.read(0x40000)})
				if (@tag_info[current] = @md5_index[md5sum])
					#log DEBUG, "Cache hit!"
					next
				end
			rescue
				log DEBUG, "Couldn't open file!"
				@tag_info.delete current
				next
			end

			# Check to see if we can load this file
			loader = nil
			@taggers.each { |x| break if (loader = x).get_tags? current }
			unless loader
				log DEBUG, "No one supports '#{current.to_s}'!" 
				next
			end

			yield(count.to_f / files.size) if (block_given? and (count % yield_every) == 0)

			if (@tag_info[current] = loader.song_info(current))
				@tag_info[current][:path] = current
				@tag_info[current][:md5sum] = md5sum
				next
			else
				log DEBUG, "Couldn't get tags for '#{current.to_s}'!"
			end

			# Can't be loaded, delete it and move on
			@tag_info.delete current
		end 

		File.open("fixture.yaml", 'w') {|x| x.puts self.to_yaml}

		save_cache

		log INFO, "Loaded #{@tag_info.size} files"
		log DEBUG, "Exiting load"
	end

	def load_cache(target = nil)
		infile  = (target || File.join(Platform.home_dir, "libcache.yaml.gz"))
		begin
			a = nil; Zlib::GzipReader.open(infile) {|x| a = YAML::load(x.read)}
			throw "Failed!" unless a.is_a? Hash and a.values.all? {|x| x.is_a? Hash}
			@tag_info = {}; a.keys.each {|x| @tag_info[x] = Song.new(a[x])}
		rescue 
			# TODO: Worst debugging message evar.
			log DEBUG, "Couldn't load cache"
			@tag_info = {}
		end

		@md5_index = {}
		@tag_info.values.each do |x|
			next unless x[:md5sum]
			@md5_index[x[:md5sum]] = x
		end
	end

	def save_cache(target = nil)
		outfile  = (target || File.join(Platform.home_dir, "libcache.yaml.gz"))
		t = {}; @tag_info.keys.each {|x| t[x] = @tag_info[x].to_hash}
		Zlib::GzipWriter.open(outfile) { |x| x.puts t.to_yaml() }
	end

	def find_soundtracks
		@is_soundtrack ||= {}
		log DEBUG, "Entering find_soundtracks"

		build_tables unless @album_info
		@album_info.keys.each do |curname|
			artists = {}
			current = @album_info[curname]

			next if @is_soundtrack.has_key? curname
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
					current.checked_tag(x, InvalidChars, lambda { |a,b,c| yield a,InvalidCharsString,c })
				end
				dest = File.join(target_root, 
						 music_fstr % data)
			else
				data = sndtrk_tags.collect do |x| 
					current.checked_tag(x, InvalidChars, lambda { |a,b,c| yield a,InvalidCharsString,c})
				end
				dest = File.join(target_root, 
						 sndtrk_fstr % data)
			end
			list << [ current[:path], dest, current ]
		end
		list
	end

	def execute_action_list(list, action, execute_class = DebugList, output_file = nil, only_execute = 0)
		do_it = execute_class.new
		do_it.begin output_file

		count = 0
		list.each do |x| 
			path = Pathname.new x[1]
			do_it.mkdirs path.dirname

			count = count + 1
			break if only_execute > 0 and count > only_execute

			begin
				case action
				when :copy
					 do_it.cp x[0], x[1], x[2]
				when :move
					 do_it.mv x[0], x[1], x[2]
				when :symlink
					 do_it.link x[0], x[1], x[2]
				end
			rescue
				log ERROR, _("Failure processing %s") % x[0]
				next
			end

		end

		do_it.finish
	end

	def load_taggers(*paths)
		paths.each do |x|
			log DEBUG, "Trying to load #{x}"
			Pathname.new(x).each_entry do |y| 
				# Canonicalize path - otherwise we'll confuse 'require'
				file = Pathname.new(File.join(x,y)).realpath
				require file if y.extname == '.rb'
			end
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
