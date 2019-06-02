using Wnck;
using Gee;

namespace Webkit2gtkGreeter {
	public struct AppOptions {
		public bool dev;
		public bool debug;
		string application_id;
	}

	public class GreeterApplication : Gtk.Application {
		Webkit2gtkGreeter.Window window;
		AppOptions options;
		ConfigReader config_rdr;

		public GreeterApplication(AppOptions opts) {
			Object(application_id: Constants.APPLICATION_ID, flags: ApplicationFlags.FLAGS_NONE);
			this.options = opts;
			this.config_rdr = new ConfigReader(Constants.CONF_DIR + "/lightdm-webkit2-greeter.conf");
			//  Bus.own_name(BusType.SESSION, "io.github.webkit2gtk-greeter.ConfigManager", BusNameOwnerFlags.NONE,
			//               config_mgr.on_bus_aquired, null, () => { warning("Could not aquire name"); });
		}

		public override void activate() {
			window = new Webkit2gtkGreeter.Window(options);
			add_window(window);

			// TODO : load active theme based on configuration
			debug("getting configuration");
			Map<string, string> greeter_setting = config_rdr.get_section("greeter");

			string theme_name = greeter_setting.get("webkit_theme");
			debug("using theme %s", theme_name);

			var url = "file:///opt/webkit2gtk-greeter/themes/default/index.html";
			debug("ensure theme exists %s", theme_name);
			if(ensure_theme_exists(theme_name)) {
				url = get_theme_url(theme_name);
			}

			if(options.dev) {
				var destination = File.new_for_path("data/themes/default/index.html");
				string path = "file://" + destination.get_path();
				debug("theme path: %s\n", path);
				url = path;
			}

			window.load(url, options.debug);
		}
		private string get_theme_url(string name) {
			var path = Constants.THEMES_DIR + Path.DIR_SEPARATOR_S + name;
			var config_path = path + Path.DIR_SEPARATOR_S + "index.theme";
			var file = File.new_for_path(config_path);
			Map<string, Map<string, string> > theme_setting = config_rdr.load_config_file(config_path);
			Map<string, string> config = theme_setting.get("theme");
			string index_path = config.get("url");
			bool is_absolute = Path.is_absolute(index_path);

			if(!is_absolute)
				index_path = path + Path.DIR_SEPARATOR_S + index_path;

			return "file://" + index_path;
		}
		private bool ensure_theme_exists(string theme) {
			var path = Constants.THEMES_DIR + Path.DIR_SEPARATOR_S + theme;
			var dir = File.new_for_path(path);
			debug("checking theme path %s", path);
			if(dir.query_exists() && dir.query_file_type(0) == FileType.DIRECTORY) {
				debug("theme folder exists, checking theme description file");
				var config_path = path + Path.DIR_SEPARATOR_S + "index.theme";
				var file = File.new_for_path(config_path);
				if(file.query_exists()) {
					Map<string, Map<string, string> > theme_setting = config_rdr.load_config_file(config_path);
					Map<string, string> config = theme_setting.get("theme");
					string index_path = config.get("url");
					bool is_absolute = Path.is_absolute(index_path);
					debug("is_absolute url %s", is_absolute.to_string());
					if(!is_absolute)
						index_path = path + Path.DIR_SEPARATOR_S + index_path;

					File index_file = File.new_for_path(index_path);
					if(file.query_exists()) {
						return true;
					}
				}
			}
			return false;
		}
	}
}
