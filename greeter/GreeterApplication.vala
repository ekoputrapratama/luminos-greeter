using Gee;
using GioUtil;

// Defined by CMake build script.
extern const string _INSTALL_PREFIX;
extern const string _SOURCE_ROOT_DIR;
extern const string _BUILD_ROOT_DIR;
extern const string _EXTENSIONS_DIR;
extern const string GETTEXT_PACKAGE;
extern const string APPLICATION_ID;


namespace LuminosGreeter {
	public struct AppOptions {
		public bool dev;
		public bool debug;
		string application_id;
	}

	public class GreeterApplication : Gtk.Application {

		public const string INSTALL_PREFIX = _INSTALL_PREFIX;
		public const string SOURCE_ROOT_DIR = _SOURCE_ROOT_DIR;
		public const string BUILD_ROOT_DIR = _BUILD_ROOT_DIR;
		public const string EXTENSIONS_DIR = _EXTENSIONS_DIR;

		// Local-only command line options
		private const string OPTION_VERSION = "version";

		private const string OPTION_DEBUG = "debug";

		private const GLib.OptionEntry[] OPTION_ENTRIES = {
			{ OPTION_DEBUG, 'd', 0, GLib.OptionArg.NONE, ref do_debug,
				/// Command line option
			  "Print debug logging", null }
		};
		LuminosGreeter.Window window;
		AppOptions options;
		ConfigReader config_rdr;
		private static bool do_debug;
		private static GreeterApplication _instance = null;
		/**
		 * Determines if this instance is running from the install directory.
		 */
		internal bool is_installed {
			get {
				return this.exec_dir.has_prefix(this.install_prefix);
			}
		}
		/** Returns the compile-time configured installation directory. */
		internal GLib.File install_prefix {
			get; private set; default = GLib.File.new_for_path(INSTALL_PREFIX);
		}
		public static GreeterApplication instance {
			get { return _instance; }
			private set {
				// Ensure singleton behavior.
				assert(_instance == null);
				_instance = value;
			}
		}

		private File exec_dir;
		private string binary;

		public GreeterApplication(AppOptions opts) {
			Object(application_id: APPLICATION_ID, flags: ApplicationFlags.FLAGS_NONE);
			this.options = opts;
			this.config_rdr = new ConfigReader(Constants.CONF_DIR + Path.DIR_SEPARATOR_S + "lightdm-webkit2-greeter.conf");

			_instance = this;
		}

		public override void activate() {
			window = new LuminosGreeter.Window(this);
			add_window(window);

			debug("getting configuration");
			Map<string, string> greeter_setting = config_rdr.get_section("greeter");

			string theme_name = greeter_setting.get("webkit_theme");
			debug("using theme %s", theme_name);

			var url = "file://" + Constants.THEMES_DIR + Path.DIR_SEPARATOR_S + "default/index.html";
			debug("ensure theme exists %s", theme_name);
			if(ensure_theme_exists(theme_name)) {
				url = get_theme_url(theme_name);
			}

			//  if(!is_installed) {
			//  	var destination = File.new_for_path("data/themes/default/index.html");
			//  	string path = "file://" + destination.get_path();
			//  	debug("theme path: %s\n", path);
			//  	url = path;
			//  }

			window.load(url, options.debug);
		}

		/**
		 * Returns the directory containing the application's WebExtension libs.
		 *
		 * When running from the installation prefix, this will be based
		 * on the Meson `libdir` option, and can be set by invoking `meson
		 * configure` as appropriate.
		 */
		public GLib.File get_extensions_dir() {
			return (is_installed)
			       ? GLib.File.new_for_path(EXTENSIONS_DIR)
			       : GLib.File.new_for_path(BUILD_ROOT_DIR).get_child("extensions");
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
			if(dir.query_exists() && is_directory(dir)) {
				debug("theme folder exists, checking theme description file");
				var config_path = path + Path.DIR_SEPARATOR_S + "index.theme";
				var file = File.new_for_path(config_path);
				if(file.query_exists()) {
					Map<string, Map<string, string> > theme_definition = config_rdr.load_config_file(config_path);
					Map<string, string> def = theme_definition.get("theme");
					string index_path = def.get("url");

					bool is_absolute = Path.is_absolute(index_path);
					debug("theme provide absolute url %s", is_absolute.to_string());

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
