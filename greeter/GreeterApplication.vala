using Wnck;

namespace Webkit2gtkGreeter {
	public struct AppOptions {
		public bool dev;
		public bool debug;
		string application_id;
	}

	public class GreeterApplication : Gtk.Application {
		Webkit2gtkGreeter.Window window;
		AppOptions options;

		public GreeterApplication(AppOptions opts) {
			Object(application_id: opts.application_id, flags: ApplicationFlags.FLAGS_NONE);
			this.options = opts;
		}

		public override void activate() {
			window = new Webkit2gtkGreeter.Window(options);
			add_window(window);

			// TODO : load active theme based on configuration
			var url = "file:///opt/webkit2gtk-greeter/themes/default/index.html";
			if(options.dev) {
				var destination = File.new_for_path("data/themes/default/index.html");
				string path = "file://" + destination.get_path();
				message("theme path: %s\n", path);
				url = path;
			}

			window.load(url, options.debug);
		}
	}
}
