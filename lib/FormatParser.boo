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
import System.Text
import System.Collections
import Mono.Unix
import Boo.Lang

public enum FormatType:
	Title
	Artist
	Album
	Length
	Genre
	Comment
	Year
	Track
	Bitrate
	SampleRate
	Channels
	Extension					// We handle this separately

public class FormatParser:

	[Property(TagSubstituteTable)]
	m_tagSubTable as Hashtable = Hashtable()

	[Property(TagSubstitutePrompt)]
	m_tagSubstHandler as TagSubstituteHandler = nullSubstituteHandler

	m_invalidChars as (char)
	m_invalidCharString as string
	InvalidCharacters as (char):
		get:
			return m_invalidChars
		set:
			m_invalidChars = value
			m_invalidCharString = join(value)

	static def nullSubstituteHandler(OrigTag as string, InvalidCharList as string) as string:
		return "[Invalid Tag]"
	
	public def constructor(SubstitutePrompt as TagSubstituteHandler, InvalidChars as (char)):
		m_tagSubstHandler, m_invalidChars = (SubstitutePrompt, InvalidChars)
	
	def getValidTagData(source as Data, type as FormatType) as string:
		// Get the tag based on the type
		tag = source.Album if type == FormatType.Album
		tag = source.Artist if type == FormatType.Artist
		tag = source.Bitrate if type == FormatType.Bitrate
		tag = source.Channels if type == FormatType.Channels
		tag = source.Comment if type == FormatType.Comment
		tag = source.Extension if type == FormatType.Extension
		tag = source.Genre if type == FormatType.Genre
		tag = source.Length if type == FormatType.Length
		tag = source.SampleRate if type == FormatType.SampleRate
		tag = source.Title if type == FormatType.Title
		tag = source.Track if type == FormatType.Track
		tag = source.Year if type == FormatType.Year

		// If we have no invalid characters, return it
		return tag if tag.IndexOfAny(m_invalidChars) == -1

		// Check the substitute table; if nothing's in there, prompt for it
		return m_tagSubTable[tag] unless m_tagSubTable[tag] == null
		orig_tag = tag
		while(true):
			new_tag = m_tagSubstHandler(tag, m_invalidCharString); 	tag = new_tag
			raise ApplicationException() if new_tag == null
			break if tag.IndexOfAny(m_invalidChars) == -1

		// Add it to our table and return
		m_tagSubTable[orig_tag] = tag
		return tag
	

	static final left_bracket = '<'[0]
	static final right_bracket = '>'[0]
	def findMatchingBracket(buf as string, LeftBracketIndex as int) as int:
		// Check our params
		raise ArgumentException("buf[index] isn't a left bracket!") unless buf[LeftBracketIndex] == left_bracket
		
		bracket_depth = 1
		i = LeftBracketIndex + 1 
		while i < buf.Length:
			bracket_depth++ if buf[i] == left_bracket
			bracket_depth-- if buf[i] == right_bracket
			break if bracket_depth == 0
			i++
		
		return i if bracket_depth == 0 
		return -1
	
	public def ParseFormatString(source as Data, FormatString as string, OverrideArtist as string) as string:
		buf = FormatString
		start_location = 0			// We use this to skip over mismatched <'s
		App.Debug("Original buf = {0}", buf)
		
		while (bracket_start = buf.IndexOf(left_bracket, start_location)) >= 0:
		
			// Find the matching end bracket. If it doesn't exist, this is the new start pos
			bracket_end = findMatchingBracket(buf, bracket_start)
			if bracket_end < 0:
				// TODO: We need to notify the user somehow if they give us a bum FormatString
				start_location = bracket_start + 1
				continue

			// Extract the tag. If they give us <> or something messed up, skip over it
			if bracket_end - bracket_start < 2:
				start_location = bracket_start + 1
				continue
			tag = buf.Substring(bracket_start + 1, bracket_end - bracket_start - 1).ToLower()
			App.Debug("Tag extracted: {0}", tag)

			// Replace it with the data. If this is a tag that we don't know about, pass it through
			if TagLibFu.TagTable[tag] == null:
				start_location = bracket_start + 1
				continue

			// Replace it, and fix the start_location index to reflect the change in length
			// We subtract an extra 2 in there to account for the brackets
			if bracket_start == 0:
				left_side = ""
			else:
				left_side = buf.Substring(0, bracket_start)
			tag_data = getValidTagData(source, TagLibFu.TagTable[tag])
			tag_data = OverrideArtist if OverrideArtist != null and tag == "artist"
			App.Debug("bracket_end = {0}, Length = {1}", bracket_end, buf.Length)
			if bracket_end == (buf.Length - 1):
				right_side = ""
			else:
				right_side = buf.Substring(bracket_end + 1, buf.Length - bracket_end - 1)	
			App.Debug("left_side = '{0}', tag_data = '{1}', right_side = '{2}'",
				  left_side, tag_data, right_side)
			buf = left_side + tag_data + right_side
			start_location += (tag_data.Length - tag.Length - 2) if start_location > 0
			App.Debug("Buf at iteration: {0}", buf)
		
		App.Debug("Buf = {0}", buf)
		return buf
