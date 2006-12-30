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

public final class PlatformFu:
	private def constructor():
		pass;
		
	static m_isWin = null
	public static def IsWindows():
		return m_isWin if m_isWin != null 
		return m_isWin = Environment.OSVersion.ToString().IndexOf("Windows") != -1

	static m_invalidWinChars = null		// \ / : * ? " < > | are all invalid
	static m_invalidUnixChars = null	// / ; : are all invalid
	public static def InvalidCharactersFromPath(RootPath as string):
		m_invalidWinChars = """\/:*?"<>|""".ToCharArray() if m_invalidWinChars == null
		m_invalidUnixChars = """/;:""".ToCharArray() if m_invalidUnixChars == null
		return m_invalidWinChars if PlatformFu.IsWindows() 
		return m_invalidUnixChars	// FIXME: If this is Unix, we have to figure out the mountpoint type

	
	
