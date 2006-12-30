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
import Glade
import Gtk

public class GtkUIHandler:
	public def Main(args as (string)) as int:
		Application.Init()
		win = mainWindow()
		win.Show()
		Application.Run()
		return 0
