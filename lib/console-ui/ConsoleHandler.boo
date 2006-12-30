/***************************************************************************
 *   Copyright (C) 2005 by Paul Betts					   *
 *   Paul.Betts@Gmail.com						   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

// created on 12/21/2005 at 13:15
namespace Estelle.UI

import System
import System.IO
import System.Collections
import Mono.Unix
import Mono.GetOptions
import Boo.Lang
import Estelle

public class ConsoleHandler:

	static def promptForSoundtrack(album as string) as bool:
		print album
		prompt_text = String.Format(_('The album "{0}" appears to be a soundtrack or compilation. Is it? (Y/n)'), album)
		while true:
			response = prompt(prompt_text)
			return true if (response.ToLower()[0] == Q_("Positive response to question|Yes").ToLower()[0])
			return false if (response.ToLower()[0] == Q_("Negative response to question|No").ToLower()[0])
	
	static def promptForTagSubstitute(OrigTag as string, InvalidCharList) as string:
		print 'DEBUG: Returning "NULL" for tag substitute'
		return "NULL"
	
	static def printLoadError(sender, path as string, message as string):
		print _("Error loading {0} - {1}...") % (path, message)

	public def Main(args as (string)) as int:
		// Parse the command line options
		try:
			App.Debug("Starting console handler")
			opts = CommandLineOpts(args, 
					       OptionsParsingMode.Both,
					       true, 	// Break -aBc into -a -B -c
					       false,	// End processing on --
					       true)	// Don't split on commas
		except e as Exception:
			print _("Error parsing options: {0}") % e.Message
			opts.DoHelp()
			return -1

		// Check our params to make sure they aren't crap
		if opts.RemainingArguments.Length != 1:
			print _("One or more parameters are invalid")
			opts.DoHelp()
			return -1
		SourcePath = PathFu.CanonicalizePath(opts.RemainingArguments[0])
		TargetPath = PathFu.CanonicalizePath(opts.Target)

		// Check to make sure the source and target folder exists
		if (source_info = DirectoryInfo(SourcePath)).Exists == false or DirectoryInfo(TargetPath).Exists == false:
			print _("The target '{0}' does not exist") % TargetPath
			opts.DoHelp()
			return -1

		// Load the music into the library
		Console.WriteLine("Finding all files");
		Library = MusicLibrary()
		Library.LoadError += printLoadError
		library_files = PathFu.FilesInDirectory(source_info)
		Console.WriteLine("Loading tags from library")
		files_tried = Library.LoadTags(library_files, promptForSoundtrack)
		App.Verbose(_("{0} files attempted, {1} files loaded"), files_tried, Library.Count)
		
		App.Debug("\nMusic Format: {0}\nSoundtrack Format: {1}\n", opts.MusicFormat, opts.SoundtrackFormat)

		// Create the action list
		Actions = Library.CreateActionList(opts.Target, opts.MusicFormat, 
						   opts.SoundtrackFormat, promptForTagSubstitute)

		// DEBUG: Print our info
		for action as FileAction in Actions:
			App.Verbose("{0} => {1}", action.SourcePath, action.DestPath)

		// Execute our list
		actionType = ActionType.Copy
		actionType = ActionType.Move if opts.Action == "move"
		actionType = ActionType.Symlink if opts.Action == "symlink"
		Library.ExecuteActionList(Actions, actionType)

		return 0
