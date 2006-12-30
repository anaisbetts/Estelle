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

public enum PathType:
	RegularFile
	Directory
	Symlink
	BlockDevice
	CharDevice
	Nonexistant

def _(s as string) as string:
	t = Globals.m_i18nCache[s]
	return t as string unless t == null
	t = Catalog.GetString(s) 
	Globals.m_i18nCache.Add(s, t) 
	return t

def Q_(s as string) as string:
	t = _(s)
	return t unless t == s and (index = t.IndexOf('|'[0])) >= 0
	print s[index+1 :]
	return s[index+1 :]

private final class Globals:
	def constructor():
		pass;
	internal static m_i18nCache = Hashtable()
	
	public final static SupportedFormats = (".mp3", ".m4a", ".m4p", ".wma", ".aac", ".ogg", ".flac", ".ape")

public final class QuickListSerializer:
	def constructor():		// No construction
		pass;

	public static def ReadList(path as string) as (string):
		// FIXME: This implementation is probably pretty slow even though it's clean
		using input_file = StreamReader(path):
			return input_file.ReadToEnd().Split('\n'[0])
	
	public static def WriteList(list as IEnumerable, path as string):
		using output_file = StreamWriter(path):
			for item in list:
				output_file.WriteLine(item.ToString())
	
	public static def ReadHashtable(path as string) as Hashtable:
		buf = Hashtable()
		using input_file = StreamReader(path):
			while (s = input_file.ReadLine()):
				key_and_value = s.Split("="[0])
				if key_and_value.Length != 2:
					raise FormatException("File is incorrectly formatted: no separator ('=')")

				// Pull off the quotes
				for i in key_and_value:
					i = i.Trim()
					if i[0 : -1] != '""':
						raise FormatException("File is incorrectly formatted: values must be quoted")
					i = i.Substring(1, i.Length - 2)
				buf[key_and_value[0]] = key_and_value[1]
		return buf
	
	public static def WriteHashtable(table as Hashtable, path as string):
		using output_file = StreamWriter(path):
			for i as DictionaryEntry in table:
				output_file.WriteLine('"{0}"="{1}', i.Key.ToString(), i.Value.ToString())

public final class PathFu:
	def constructor():		// No construction
		pass;
		
	public static def FilesInDirectory(root as DirectoryInfo) as (string):
		temp = ArrayList() 
		addFilesToList(root, temp)
		return temp.ToArray(typeof(string)) as (string)
	
	static def addFilesToList(root as DirectoryInfo, theList as ArrayList):
		for i in root.GetFiles():
			theList.Add(i.FullName)
		for j in root.GetDirectories():
			addFilesToList(j, theList)
	
	public static def CanonicalizePath(path as string):
		return Path.GetFullPath(path) if PlatformFu.IsWindows() or path.Length == 0 or path[0] != '~'[0]

		// If this is *nix, handle ~ and ~[user]
		firstslash = path.IndexOf('/'[0])
		firstslash = path.Length if firstslash < 0 
		user = path[1:firstslash]
		user = Environment.UserName if user == ""
		try:
			return Path.GetFullPath(path.Replace('~' + user, Native.Syscall.getpwnam(user).pw_dir));
		except:
			raise ApplicationException("User does not exist")
	
	public static def GetPathType(path as string) as PathType:
		current_type = PathType.Nonexistant
		f = FileInfo(path)
		if not f.Exists:
			d = DirectoryInfo(path)
			current_type = PathType.Directory if d.Exists
		else: 
			current_type = PathType.RegularFile
		return current_type if PlatformFu.IsWindows()
		
		// If this is *nix, we have some additional types to check for
		// The next section only works on *nix 
		ufi = UnixFileInfo(path)
		return PathType.BlockDevice if ufi.IsBlockDevice
		return PathType.CharDevice if ufi.IsCharacterDevice
		return PathType.Symlink if ufi.IsSymbolicLink
		return PathType.Nonexistant if not ufi.Exists
		return current_type
	
	public static def CreateDirectoriesFromPath(path as string):
		current_path = '/' 	// Path.Combine sucks, we have to shim it
		current_path = '' if PlatformFu.IsWindows()
		return if path.Length == 0

		for i in PathFu.CanonicalizePath(path).Split(Path.DirectorySeparatorChar):
			continue if i.Length == 0
			App.Debug(" i = {0}, current_path = {1}" % (i, current_path))

			// If this is a drive, we can't do anything about this
			if i.IndexOf(Path.VolumeSeparatorChar) >= 0:	
				App.Debug("Volume'd?!")
				current_path = Path.Combine(current_path, i)
				d = DirectoryInfo(current_path)
				raise ApplicationException(_("The drive does not exist")) if not d.Exists
				continue

			// Check to see if the directory exists
			child = DirectoryInfo(Path.Combine(current_path, i))
			if child.Exists:
				current_path = Path.Combine(current_path, i)
				continue;
			else:
				parent = DirectoryInfo(current_path)
				parent.CreateSubdirectory(i)
				current_path = Path.Combine(current_path, i)
				continue;
	
	public static def TagIsValid(TagText as string, RootPath as string):
		return false if TagText.Length == 0
		return (TagText.IndexOfAny(PlatformFu.InvalidCharactersFromPath(RootPath)) == -1)

public class TagLibFu:
	def constructor():
		pass;
	
	static m_unknownTable = Hashtable()
	public static UnknownTable:
		get:
			//return m_unknownTable if m_unknownTable != null and m_unknownTable.Count > 0
			m_unknownTable = Hashtable()
			m_unknownTable.Add(FormatType.Title, _("Unknown Title"));
			m_unknownTable.Add(FormatType.Artist, _("Unknown Artist"));
			m_unknownTable.Add(FormatType.Album, _("Unknown Album"));
			m_unknownTable.Add(FormatType.Genre, _("Unknown Genre"));
			m_unknownTable.Add(FormatType.Year, _("Unknown Year"));
			m_unknownTable.Add(FormatType.Track, _("Unknown Track"));
			m_unknownTable.Add(FormatType.Length, _("Unknown Length"));
			m_unknownTable.Add(FormatType.Bitrate, _("Unknown Bitrate"));
			m_unknownTable.Add(FormatType.SampleRate, _("Unknown Sample Rate"));
			m_unknownTable.Add(FormatType.Channels, _("Unknown Number of Channels"));
			m_unknownTable.Add(FormatType.Comment, _("No Comment"));
			m_unknownTable.Add(FormatType.Extension, "");   // Probably not gonna happen
			return m_unknownTable
	
	static m_tagTable = Hashtable();
	public static TagTable:
		get:
			return m_tagTable if m_tagTable.Count > 0
			m_tagTable = Hashtable()
			m_tagTable.Add("title", FormatType.Title) 
			m_tagTable.Add("artist", FormatType.Artist)
			m_tagTable.Add("album", FormatType.Album)
			m_tagTable.Add("genre", FormatType.Genre)
			m_tagTable.Add("year", FormatType.Year)
			m_tagTable.Add("track", FormatType.Track)
			m_tagTable.Add("length", FormatType.Length)
			m_tagTable.Add("bitrate", FormatType.Bitrate)
			m_tagTable.Add("samplerate", FormatType.SampleRate)
			m_tagTable.Add("channels", FormatType.Channels)
			m_tagTable.Add("comment", FormatType.Comment)
			m_tagTable.Add("ext", FormatType.Extension) 
			m_tagTable.Add("extension", FormatType.Extension) 
			return m_tagTable
			
	public static def Album(file as TagLib.File) as string:
		item = file.Tag.Album if file.Tag != null
		return item.Trim() if item != null and item.Length > 0
		return UnknownTable[FormatType.Album] as string 
	
	public static def Artist(file as TagLib.File) as string:
		item = file.Tag.Artist if file.Tag != null
		return item.Trim() if item != null and item.Length > 0
		return UnknownTable[FormatType.Artist] as string 
	
	public static def Title(file as TagLib.File) as string:
		item = file.Tag.Title if file.Tag != null
		return item.Trim() if item != null and item.Length > 0
		return UnknownTable[FormatType.Title] as string 
	
	public static def Length(file as TagLib.File) as string:
		item = file.AudioProperties.Length if file.AudioProperties != null
		return "{0}:{1}" % (item / 60, item % 60) if item > 0 
		return UnknownTable[FormatType.Title] as string

	public static def Genre(file as TagLib.File) as string:
		item = file.Tag.Genre if file.Tag != null
		return item.Trim() if item != null and item.Length != 0
		return UnknownTable[FormatType.Genre] as string

	public static def Comment(file as TagLib.File) as string:
		item = file.Tag.Comment if file.Tag != null
		return item.Trim() if item != null and item.Length > 0 
		return UnknownTable[FormatType.Comment] as string

	public static def Year(file as TagLib.File) as string:
		item = file.Tag.Year if file.Tag != null
		return item.ToString() if item > 0 
		return UnknownTable[FormatType.Year] as string
	
	public static def Track(file as TagLib.File) as string:
		return file.Tag.Track.ToString() if file.Tag != null
		return (UnknownTable[FormatType.Track]) as string			    		
		
	public static def Bitrate(file as TagLib.File) as string:
		item = file.AudioProperties.Bitrate if file.AudioProperties != null
		return item.ToString() if item > 0 
		return UnknownTable[FormatType.Bitrate] as string			    		

	public static def SampleRate(file as TagLib.File) as string:
		item = file.AudioProperties.SampleRate if file.AudioProperties != null
		return item.ToString() if item > 0 
		return UnknownTable[FormatType.SampleRate] as string			    		
	
	public static def Channels(file as TagLib.File) as string:
		item = file.AudioProperties.Channels if file.AudioProperties != null
		return item.ToString() if item > 0 
		return UnknownTable[FormatType.Channels] as string			    		
