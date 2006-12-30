
import System

namespace estelle

public class MainWindow(Gtk.Window):
	
	public def constructor() :
		super("")
		Stetic.Gui.Build(self, typeof(estelle.MainWindow))

