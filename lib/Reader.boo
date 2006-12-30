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

namespace Estelle

import System
import System.IO
import System.Text
import System.Collections
import Mono.Unix
import Boo.Lang

public class Data:
	public Title as string
	public Album as string
	public Comment as string
	public Genre as string
	public Year as string
	public Track as string

	artist as string
	public Artist as string:
		get:
			return artist
		set:
			artist = value
			updateArtistInfo()

	canonicalArtist as string
	public CanonicalArtist as string:
		get:
			return canonicalArtist unless canonicalArtist == null
			return (canonicalArtist = join(i.Key as string for i as DictionaryEntry in ArtistList))

	public ArtistList = SortedList()

	public Length as string
	public Bitrate as string
	public SampleRate as string
	public Channels as string

	m_path as string
	public Path as string:
		get:
			return m_path
		set:
			m_path = value
			m_ext = null		// Force the extension to recalc
	
	m_ext as string	
	public Extension as string:
		get:
			return m_ext unless m_ext == null
			return (m_ext = System.IO.Path.GetExtension(m_path)[1 : ]) 	// Take off the '.'

	public def constructor():
		pass;
	
	private m_artistSplitChars = """;,/\|-""".ToCharArray()
	private m_artistSplitList
	public def constructor(path as string):
		d = Data()
		f = TagLib.File(path)
		Title, Album, Comment, Genre, Year, Track = (TagLibFu.Title(f), TagLibFu.Album(f), TagLibFu.Comment(f),
							     TagLibFu.Genre(f), TagLibFu.Year(f), TagLibFu.Track(f))
		Track = "0" + Track if Track.Length == 1
		Length, Bitrate, SampleRate, Channels, Path = (TagLibFu.Length(f), TagLibFu.Bitrate(f),
							       TagLibFu.SampleRate(f), TagLibFu.Channels(f), path)

		// Parse the artist list; songs may have > 1 artist (think "Queen feat. David Bowie" or something)
		Artist = TagLibFu.Artist(f)
		App.Debug("Original artist string: {0}", Artist)
		updateArtistInfo()
		f.Dispose()

	def updateArtistInfo():
		// This is the easy, I18N-safe way; replace all words like 'featuring', 'feat.', etc with semicolons,
		// then Split the string and add the items to a sorted list so we don't have to deal with permutations
		// We load the word list from a file in the app directory
		buf = StringBuilder(Artist)
		loadArtistSplitList() unless m_artistSplitList
		for current in m_artistSplitList:
			buf.Replace(current, "; ")

		App.Debug("Artist string before split: {0}", buf.ToString())
		artists = buf.ToString().Split(m_artistSplitChars, 256)
		ArtistList.Clear()
	
		for current as string in artists:
			s = current.Trim()
			ArtistList.Add(s, null) unless ArtistList.ContainsKey(s)

		// Force the property to rebuild its cached info
		canonicalArtist = null
	
	def loadArtistSplitList():
		// TODO: Fix this so it actually does something
		m_artistSplitList = ArrayList()
