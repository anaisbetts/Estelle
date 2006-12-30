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
namespace Estelle

import System
import System.IO
import System.Collections
import Mono.Unix
import Boo.Lang

public callable VerifySoundtrackHandler(album as string) as bool
public callable FileHandler(sender, path as string, message as string)
public callable TagSubstituteHandler(OrigTag as string, InvalidCharList as string) as string

public enum ActionType:
	Copy
	Move
	Symlink

public struct FileAction:
	SourcePath as string
	DestPath as string

	public def constructor(source as string, dest as string):
		SourcePath, DestPath = (source, dest)

public class MusicLibrary:

	// This is the primary data set, it's a list of all the files we've found 
	// and the Data structure associated with it
	fileInfo = Hashtable()

	// This table is structured exactly like fileInfo, only it has tracks that are
	// on a soundtrack or compilation
	soundtrackInfo = Hashtable()

	// This is a list of names of soundtracks or compilations
	soundtrackList = ArrayList()

	// This is a list of albums that the primary artist must be determined. For example,
	// American IV is by Johnny Cash, yet several of the tracks have other artists as well
	// as him. 
	multipleArtistList = Hashtable()

	// This is a table of albums, and a list of the tracks on them. It is structured, 
	// {<Album name>, <ArrayList of Data classes that are the tracks on said album>}
	albumInfo = Hashtable()

	public def constructor():
		pass;
		
	public def LoadTags(Files as (string), verifier as VerifySoundtrackHandler) as int:
		fileInfo.Clear()
		files_tried = 0
		for current in Files:
			App.Debug("Reading {0}...", current)
			continue if Array.IndexOf(Globals.SupportedFormats, Path.GetExtension(current).ToLower()) == -1	
			files_tried++;
			try:
				fileInfo.Add(current, Data(current))
			except e as Exception:
				LoadError(self, current, 
					  _("Couldn't get tag info for {0}: {1}") % (current, e.ToString()))
		
		buildTables()
		findSoundtracks(verifier)
		return files_tried	
	
	public def LoadTags(PlaylistFile as StreamReader, verifier as VerifySoundtrackHandler): 
		line = PlaylistFile.ReadLine()
		buf = []
		while(line != null):
			buf += line
			line = PlaylistFile.ReadLine()
		LoadTags(buf as (string), verifier)
	
	def buildTables():
		/* Build the artist and album tables; these tables basically let us quickly go through
		 * this information without being too huge (it only stores refs to the entry in the fileList) */
		//artistInfo.Clear()
		albumInfo.Clear()
		for current as DictionaryEntry in fileInfo:
			artist = (current.Value as Data).CanonicalArtist	// Get the artist and album
			album = (current.Value as Data).Album
			//artistInfo.Add(artist, ArrayList()) unless artistInfo.ContainsKey(artist)
			albumInfo.Add(album, ArrayList()) unless albumInfo.ContainsKey(album)
			//(artistInfo[artist] as ArrayList).Add(current.Value)	// Add the current items to the list
			(albumInfo[album] as ArrayList).Add(current.Value)
	
	def findSoundtracks(handler as VerifySoundtrackHandler):
		artists = Hashtable()				// Ghetto version of a set
		for item as DictionaryEntry in albumInfo:
			artists.Clear()
			track_list = item.Value as ArrayList
			album = item.Key as string
			for track as Data in track_list:
				continue if artists.ContainsKey(track.CanonicalArtist)
				artists.Add(track.CanonicalArtist, null)

			// TODO: This shouldn't call the handler if it's an album where every
			// artist has a "featuring..."
			App.Verbose("{0} artists for album {1}", artists.Count, album)
			
			// We have to do special processing on albums that have > 1 artist but one primary artist
			continue if artists.Count < 2
			if artists.Count < 3 or handler(album) == false:
				multipleArtistList.Add(album, null)
				continue
			
			// The handler affirmed that it is a soundtrack, move the tracks
			for track as Data in track_list:
				fileInfo.Remove(track.Path)
				soundtrackInfo.Add(track.Path, track)
				soundtrackList.Add(album)
	
	public def CreateActionList(TargetRoot as string, MusicFormat as string, SoundtrackFormat as string,
				    prompt as TagSubstituteHandler) as (FileAction):
		// Process the regular albums and then the soundtracks
		// TODO: Somewhere we need to load the substitution table!
		track_lists = (fileInfo, soundtrackInfo)
		track_formats = (MusicFormat, SoundtrackFormat)
		parser = FormatParser(prompt, PlatformFu.InvalidCharactersFromPath(TargetRoot))
		action_list = ArrayList()
	
		// Handle the soundtracks first
		for item as DictionaryEntry in soundtrackInfo:
			current_path = item.Key as string
			current_tag = item.Value as Data
			App.Verbose("Processing {0}...", current_path)
			
			dest_path = Path.Combine(TargetRoot, 
						 parser.ParseFormatString(current_tag, SoundtrackFormat, null))
			action_list.Add(FileAction(current_path, dest_path))

		// Handle the regular albums
		album_artist_table = Hashtable()
		current_artist_table = Hashtable()
		for item as DictionaryEntry in fileInfo:
			current_path = item.Key as string
			current_tag = item.Value as Data
			
			// Figure out if we need to find out the actual artist for this album
			// FIXME: This code looks ugly.
			App.Verbose("Processing {0}...", current_path)
			theAlbum = current_tag.Album
			if (s = album_artist_table[theAlbum]) != null:
				album_artist = s
			elif multipleArtistList.ContainsKey(current_tag.Album):
				// Build a list of all the artists on the album
				current_artist_table.Clear()
				for track as Data in (albumInfo[theAlbum] as ArrayList):
					for current_artist in track.ArtistList:
						// FIXME: This boxes like mad
						current_artist_table.Add(current_artist, 0) unless current_artist_table.ContainsKey(current_artist)
						current_artist_table[current_artist] = cast(int, current_artist_table[current_artist]) + 1
				
				// Find the largest one in the list and set the album artist to it
				max_count = 0
				for tableItem as DictionaryEntry in current_artist_table:
					continue if cast(int, tableItem.Value) < max_count
					album_artist = tableItem.Key as string
					max_count = cast(int, tableItem.Value)
				album_artist_table[theAlbum] = album_artist
			else:
				album_artist = current_tag.Artist
			
			print "Entering ParseFormatString?"
			dest_path = Path.Combine(TargetRoot, 
						 parser.ParseFormatString(current_tag, MusicFormat, album_artist))
			action_list.Add(FileAction(current_path, dest_path))
		
		
		return action_list.ToArray(typeof(FileAction)) as (FileAction)
	
	public def ExecuteActionList(actionList as (FileAction), type as ActionType):
		if PlatformFu.IsWindows() and type == ActionType.Symlink:
			raise ArgumentException("Windows doesn't support symbolic links")
		
		// Iterate through the action list copying / moving files
		for current as FileAction in actionList:
			f = System.IO.FileInfo(current.SourcePath)
			App.Debug("DestPath = {0}", current.DestPath);
			PathFu.CreateDirectoriesFromPath(Path.GetDirectoryName(current.DestPath))
			f.CopyTo(current.DestPath, true) if type == ActionType.Copy or type == ActionType.Move
			try:
				f.Delete() if type == ActionType.Move
			except e as Exception:
				pass;			// Ignore delete failures (FIXME: Is this a good idea?)
			
			continue unless type == ActionType.Symlink
			uf = UnixFileInfo(current.SourcePath)
			uf.CreateSymbolicLink(current.DestPath)
					
			
	public Count as int:
		get:
			return fileInfo.Count + soundtrackInfo.Count
	
	public event FileProcessed as FileHandler 
	public event LoadError as FileHandler
