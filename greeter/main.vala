
using GLib;
namespace Webkit2gtkGreeter {
	bool do_show_version = false;
	bool do_debug = false;
	bool dev = false;
	class Webkit2gtkGreeterApp : Gtk.Application {
		Webkit2gtkGreeter.Window window;

		public Webkit2gtkGreeterApp(string? application_id, ApplicationFlags flags) {
			Object(application_id: application_id, flags: flags);
		}

		public override void activate() {
			this.init();
			window = new Webkit2gtkGreeter.Window(dev);
			add_window(window);
			var url = "file:///opt/webkit2gtk-greeter/static/index.html";
			if(dev) {
				var destination = File.new_for_path("data/themes/default/index.html");
				string path = "file://" + destination.get_path();
				message("theme path: %s\n", path);
				url = path;
			}

			window.load(url, true);
		}
		public void init() {
			unowned Wnck.Screen screen = Wnck.Screen.get_default();
			//  Wnck.set_client_type(Wnck.ClientType.PAGER);
			// Make sure internal window-list of Wnck is most up to date
			Gdk.error_trap_push();
			screen.force_update();

			if(Gdk.error_trap_pop() != 0)
				critical("Wnck.Screen.force_update() caused a XError");

			unowned GLib.List<Wnck.Window> window_list = screen.get_windows();
			screen.window_manager_changed.connect_after(window_manager_changed);
			screen.window_closed.connect_after(handle_window_closed);

			message("Window-manager: %s", screen.get_window_manager_name());

		}
		public void window_manager_changed(Wnck.Screen screen) {
			message("window_manager_changed");
		}
		public void handle_window_closed(Wnck.Window window) {
			message("window_closed");
		}
		public static string? get_window_icon(Wnck.Window window)
		{
			unowned Wnck.Window w = window;
			unowned Gdk.Pixbuf ? pbuf = null;
			string ? image = "";

			warn_if_fail(w != null);

			if(w == null)
				return null;

			Gdk.error_trap_push();

			pbuf = w.get_icon();
			if(w.get_icon_is_fallback())
				pbuf = null;

			if(Gdk.error_trap_pop() != 0)
				critical("get_window_icon() for '%s' caused a XError", window.get_name());

			if(pbuf != null) {
				uint8[] buffer;
				var saved = pbuf.save_to_buffer(out buffer, "png");
				if(saved) {
					image = GLib.Base64.encode(buffer);
				} else {
					image = null;
				}
			}
			return image;
		}
	}

	static int main(string[] args) {
		OptionEntry versionOption = { "version", 'v', 0, OptionArg.NONE, ref do_show_version,
			                      /* Help string for command line --version flag */
			                      N_("Show release version"), null };
		OptionEntry debugOption = { "debug", 'd', 0, OptionArg.NONE, ref do_debug,
			                    N_("Enable debugging features"), null };
		OptionEntry devOption = { "dev", 'c', 0, OptionArg.NONE, ref dev,
			                  N_("Running in development mode"), null };
		OptionEntry[] options = { versionOption, debugOption, devOption };

		message("Loading command line options");
		var c = new OptionContext("- Webkit2gtk Greeter");
		c.add_main_entries(options, "io.github.webkit2gtk-greeter");
		c.add_group(Gtk.get_option_group(true));
		try
		{
			c.parse(ref args);
		}
		catch(Error e)
		{
			stderr.printf("%s\n", e.message);
			/* Text printed out when an unknown command-line argument provided */
			stderr.printf("Run '%s --help' to see a full list of available command line options.", args[0]);
			stderr.printf("\n");
			return Posix.EXIT_FAILURE;
		}
		if(do_show_version)
		{
			/* Note, not translated so can be easily parsed */
			stderr.printf("webkit2gtk-greeter %s\n", Constants.VERSION);
			return Posix.EXIT_SUCCESS;
		}
		return new Webkit2gtkGreeterApp("io.github.webkit2gtk-greeter", ApplicationFlags.FLAGS_NONE).run(args);
	}
}
