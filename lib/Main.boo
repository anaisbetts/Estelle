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
import System.Reflection
import System.Collections
import Mono.Unix
import Boo.Lang
import Estelle.UI

public class App:
	//#ifdef DEBUG
	public static VerboseMode = true
	//#else
	//public static VerboseMode = false
	//#endif

	static m_consoleWriteLine as MethodInfo
	public static def Verbose(message as string, *params):
		return if not VerboseMode 
		if m_consoleWriteLine == null:
			targetParams = (typeof(string), typeof((object)))
			m_consoleWriteLine = typeof(Console).GetMethod("WriteLine", targetParams)
		m_consoleWriteLine.Invoke(null, (message, params))
	
	public static def Debug(message as string, *params):
		//#ifdef DEBUG
		if m_consoleWriteLine == null:
			targetParams = (typeof(string), typeof((object)))
			m_consoleWriteLine = typeof(Console).GetMethod("WriteLine", targetParams)
		m_consoleWriteLine.Invoke(null, (message, params))
		//#endif

	
public def Main(args as (string)) as int:
	// If we don't have any command-line flags, start up the GUI
	Catalog.Init(Config.AppName, Config.LocaleDir)
	return GtkUIHandler().Main(args) if args.Length < 1 
	return ConsoleHandler().Main(args)
