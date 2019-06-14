//  using Gio;

namespace Luminos.Utility {
	public static Gee.Map<string, Gee.TreeMap<string, string> > load_config_file(string conffile) {

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
			//  configStr = text.str;
		} catch(GLib.IOError e) {
			error("%s", e.message);
		} catch(RegexError e) {
			error("%s", e.message);
		} catch(GLib.Error e) {
			error("%s", e.message);
		}

		return conf;
	}

	public static bool is_valid_bgconf(string path) {
		debug("is_valid_bgconf %s", path);
		var file = File.new_for_path(path);
		if(file.query_exists() && !is_directory(file)) {
			var conf = load_config_file(path);
			var bgconf = conf.get("background");
			return bgconf != null;
		}
		return false;
	}

	public static bool is_html_bg(string path) {
		var file = File.new_for_path(path);
		if(file.query_exists() && is_directory(file)) {
			var p = path + Path.DIR_SEPARATOR_S + "index.bg";
			if(file_path_exists(p) && is_valid_bgconf(p)) {
				return true;
			}
		}
		return false;
	}

	public static bool file_path_exists(string path) {
		return FileUtils.test(path, FileTest.EXISTS);
	}

	public static string? get_file_extension(string basename) {
		debug("get_file_extension: %s", basename);
		try {
			var regex = new Regex("\\.([0-9a-z]+)$");
			string[] result = regex.split(basename);
			if(result.length > 1) {
				debug("file extension: %s", result[1]);
				return result[1];
			}
		} catch(RegexError e) {
			critical("invalid regex used : %s", e.message);
		}
		return null;
	}

	public static string array_string_to_string(string[] array) {
		string result = "[";
		for(int i = 0; i < array.length; i++) {
			if(i == (array.length - 1)) {
				result += array[i] + "]";
			} else {
				result += array[i] + ",";
			}
		}
		if(array.length < 1) {
			result += "]";
		}
		return result;
	}

	public static bool is_directory(File file) {
		return file.query_file_type(0) == FileType.DIRECTORY;
	}

	public static bool is_directory_info(FileInfo file) {
		return file.get_file_type() == FileType.DIRECTORY;
	}

}
