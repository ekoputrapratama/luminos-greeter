using JS;
using Gee;
namespace Luminos {

	public class ConfigReader : GLib.Object {
		private Gee.Map<string, Gee.TreeMap<string, string> > config;
		private string configStr;
		private string[] defaultConf = {
			"#",
			"# [greeter]",
			"# detect_theme_errors = Provide an option to load a fallback theme when theme errors are detected.",
			"# screensaver_timeout = Blank the screen after this many seconds of inactivity.",
			"# secure_mode         = Don't allow themes to make remote http requests.",
			"# time_format         = A moment.js format string so the greeter can generate localized time for display.",
			"# time_language       = Language to use when displaying the time or 'auto' to use the system's language.",
			"# webkit_theme        = Webkit theme to use.",
			"#",
			"# NOTE: See moment.js documentation for format string options: http://momentjs.com/docs/#/displaying/format/",
			"#",
			"",
			"[greeter]",
			"detect_theme_errors = true",
			"screensaver_timeout = 300",
			"secure_mode         = true",
			"time_format         = LT",
			"time_language       = auto",
			"webkit_theme        = luminos",
			"",
			"#",
			"# [branding]",
			"# background_images = Path to directory that contains background images for use by themes.",
			"# logo              = Path to logo image for use by greeter themes.",
			"# user_image        = Default user image/avatar. This is used by themes for users that have no .face image.",
			"#",
			"# NOTE: Paths must be accessible to the lightdm system user account (so they cannot be anywhere in /home)",
			"#",
			"",
			"[branding]",
			"background_images = /usr/share/backgrounds",
			"logo              = /usr/share/pixmaps/manjaro.png",
			"user_image        = /usr/share/pixmaps/manjaro-logo-user.png"
		};
		public ConfigReader(string path) {
			debug("checking file %s", path);
			// default config
			var p = Constants.CONF_DIR + Path.DIR_SEPARATOR_S + "luminos-greeter.conf";
			if(config_exists(p)) {
				debug("load config file");
				config = load_config_file(path);
			} else {
				// if it's not found try to load antergos config and create a new one if antergos web-greeter doesn't exists too
				p = Constants.CONF_DIR + Path.DIR_SEPARATOR_S + "lightdm-webkit2-greeter.conf";
				if(config_exists(p)) {
					debug("load config file");
					config = load_config_file(p);
				} else {
					setup_default_config();
				}
			}
		}

		public bool config_exists(string path) {
			File file = File.new_for_path(path);
			return file.query_exists();
		}

		public void setup_default_config() {
			var conf = new Gee.TreeMap<string, Gee.TreeMap<string, string> >();
			var text = new StringBuilder();
			string[] split;
			try {
				var section = new Regex("^\\[([^\\]]+)]$");
				var comment = new Regex("^#.*$");
				var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");
				Gee.TreeMap<string, string>? curSec = null;
				string current_section_name = null;

				configStr = text.str;
				for(var i = 0; i < defaultConf.length; i++) {
					var line = defaultConf[i] + "\n";
					text.append(line + "\n");
					if(comment.match(line)) continue;

					split = regex.split(line);
					var res = section.split(line);
					if(res.length > 1) {
						current_section_name = res[1].strip();
						debug("create new section %s\n", current_section_name);
						curSec = new Gee.TreeMap<string, string>();
						conf.set(current_section_name, curSec);
					} else if(curSec == null) {
						//  throw new ConfigManagerException.MISSING_SECTION_HEADER("");
					} else {
						res = regex.split(line);
						if(res.length > 1) {
							var key = res[1];
							var value = res[2];
							curSec.set(key, value);
							conf.set(current_section_name, curSec);
							debug("adding key value %s=%s to section %s", key, value, current_section_name);
						} else {
							//  throw new ConfigManagerException.PARSE_ERROR("");
						}
					}
				}
			} catch(RegexError e) {
				critical("invalid regex used : %s", e.message);
			}
			config = conf;
		}
		public Gee.Map<string, string> get_section(string section) {
			return config.get(section);
		}

		public string to_string(string? section_name) {
			debug("config \n %s \n", configStr);
			if(section_name != null) {
				Gee.Map<string, string> section = config.get(section_name);
				var text = new StringBuilder();
				text.append("[" + section_name + "]\n");
				debug("section length %d", section.entries.size);
				foreach(Gee.Map.Entry<string, string> e in section.entries) {
					debug("adding entry %s=%s\n", e.key, e.value);
					text.append(e.key + " = " + e.value + "\n");
				}
				return text.str;
			} else {
				return configStr;
			}
		}
		public Gee.Map<string, Gee.TreeMap<string, string> > load_config_file(string conffile) {

			// A reference to our file
			var file = File.new_for_path(conffile);
			var conf = new Gee.TreeMap<string, Gee.TreeMap<string, string> >();
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var in_stream = new DataInputStream(file.read(null));
				var text = new StringBuilder();
				string line;
				string[] split;
				var section = new Regex("^\\[([^\\]]+)]$");
				var comment = new Regex("^#.*$");
				var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");
				Gee.TreeMap<string, string>? curSec = null;
				string current_section_name = null;
				// Read lines until end of file (null) is reached
				while((line = in_stream.read_line(null, null)) != null) {
					text.append(line + "\n");
					if(comment.match(line)) continue;

					split = regex.split(line);
					var res = section.split(line);
					if(res.length > 1) {
						current_section_name = res[1].strip();
						debug("create new section %s\n", current_section_name);
						curSec = new Gee.TreeMap<string, string>();
						conf.set(current_section_name, curSec);
					} else if(curSec == null) {
						//  throw new ConfigManagerException.MISSING_SECTION_HEADER("");
					} else {
						res = regex.split(line);
						if(res.length > 1) {
							var key = res[1];
							var value = res[2];
							curSec.set(key, value);
							conf.set(current_section_name, curSec);
							debug("adding key value %s=%s to section %s", key, value, current_section_name);
						} else {
							//  throw new ConfigManagerException.PARSE_ERROR("");
						}
					}
				}
				configStr = text.str;
			} catch(GLib.IOError e) {
				error("%s", e.message);
			} catch(RegexError e) {
				error("%s", e.message);
			} catch(GLib.Error e) {
				error("%s", e.message);
			}

			return conf;
		}
	}
}
