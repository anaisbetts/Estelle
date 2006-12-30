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
require 'library'
require 'optparse'
require 'optparse/time'

include GetText

$logging_level = Logger::ERROR

class Estelle < Logger::Application
	def initialize
		super(self.class.to_s) 
		self.level = $logging_level
	end

	def parse(args)

		# Set the defaults here
		results = { :target => '.', 
			    :musicformat => "<artist>/<album>/<track> - <title>.<ext>",
			    :sndtrkformat => _("Soundtracks/<album>/<track> - <title> (<artist>).<ext>"),
			    :action => :copy, :script => ''
			  }

		opts = OptionParser.new do |opts|
			opts.banner = _("Usage: Estelle [options]")

			opts.separator ""
			opts.separator _("Specific options:")

			opts.on('-a', _('--action type'), [:copy, :move, :symlink],
				_("Action to perform (one of 'copy', 'move', 'symlink')")) do |x|
				results[:action] = x.to_sym
			end

			opts.on('-c', _('--script [file]'), _('Instead of performing the action, make a script')) do |x|
				results[:script] = x
			end

			opts.on('-l', _("--library /path/to/music"),
				_("Directory to recursively scan for music")) do |x|
				results[:dir] = x 
			end

			opts.on('-m', _("--musicformat <format>"),
				_("Format to rename music (see man page for details)")) do |x|
				results[:musicformat] = x 
			end

			opts.on('-s', _("--soundtrackformat <format>"),
				_("Format to rename soundtracks (see man page for details)")) do |x|
				results[:sndtrkformat] = x 
			end

			opts.on('-p', _("--playlist file"),
				_("Playlist to read for file list")) do |x|
				results[:playlist] = x
			end

			opts.on('-t', "--target dir", _("Directory to put music in")) do |x|
				results[:target] = x
			end

			opts.separator ""
			opts.separator _("Common options:")

			opts.on_tail("-h", "--help", _("Show this message") ) do
				puts opts
				exit
			end

			opts.on('-d', "--debug", _("Run in debug mode (Extra messages)")) do |x|
				$logging_level = DEBUG
			end

			opts.on('-v', "--verbose", _("Run verbosely")) do |x|
				$logging_level = INFO 
			end

			opts.on_tail("--version", _("Show version") ) do
				puts OptionParser::Version.join('.')
				exit
			end
		end

		opts.parse!(args);	results
	end

	def filelist_from_root(path)
		list = []
		d = Pathname.new path
		d.find { |x| list << x.to_s }

		list
	end

	def run
		# Parse arguments
		begin
			results = parse(ARGV)
		rescue OptionParser::MissingArgument
			puts _('Missing parameter; see --help for more info')
			exit
		rescue OptionParser::InvalidOption
			puts _('Invalid option; see --help for more info')
			exit
		end

		self.level = $logging_level
		log DEBUG, 'Starting application'

		# Figure out a list of files to load
		file_list = []
		if results.has_key? :dir
			file_list = filelist_from_root results[:dir]
		end

		if file_list.size == 0
			file_list = ARGV
		end

		# Process the library
		library = MusicLibrary.new
		library.load file_list do |progress|
			puts _("%s%% complete") % (progress * 100.0)
		end

		library.find_soundtracks do |curname|
			print _("'%s' may be a soundtrack or compilation. Is it? (Y/n) ") % curname
			(STDIN.gets =~ /^[Nn]/ ? false : true)
		end

		log DEBUG, "Just exited!"
		list = library.create_action_list(results[:target], 
						  results[:musicformat], 
						  results[:sndtrkformat]) do |tag, invalid|
			puts _("The tag '%s' has invalid characters; '%s' are not allowed") % [tag, invalid]
			puts _("Please enter a replacement:")
			STDIN.gets
		end

		# Execute the list
		log INFO, _("Executing request...");
		do_it_class = ExecuteList; do_it_class = ShellScriptList if results[:script] != ''
		library.execute_action_list(list, 
					    results[:action], 
					    (results[:script].empty?) ? ExecuteList : ShellScriptList,
					    results[:script])

		log DEBUG, 'Exiting application'
	end
end


$the_app = Estelle.new
$the_app.run
