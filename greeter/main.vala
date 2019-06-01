
using GLib;
namespace Webkit2gtkGreeter {

	static int main(string[] args) {
		bool do_show_version = false;
		bool do_debug = false;
		bool dev = false;

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
			stderr.printf(Constants.GETTEXT_PACKAGE + " %s\n", Constants.VERSION);
			return Posix.EXIT_SUCCESS;
		}
		AppOptions opts = {false};
		opts.dev = dev;
		opts.debug = do_debug;
		opts.application_id = Constants.APPLICATION_ID;

		return new Webkit2gtkGreeter.GreeterApplication(opts).run(args);
	}
}
