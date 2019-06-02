using JS;
using Gee;
namespace WebkitGtkGreeter {

	public class ConfigReader : GLib.Object {
		private Gee.Map<string, Gee.TreeMap<string, string> > config;
		private string configStr;

		public ConfigReader(string path) {
			debug("checking file %s", path);
			File file = File.new_for_path(path);
			if(file.query_exists()) {
				debug("load config file");
				config = load_config_file(path);
			}
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
