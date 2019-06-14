/* Copyright 2016 Software Freedom Conservancy Inc.
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

/**
 * Utility functions for GIO objects.
 */
namespace Luminos.GioUtil {

	public const string GREETER_RESOURCE_PREFIX = "/io/github/luminos-greeter/";
	public Gee.Map<string, string>? mimetypes = null;
	/**
	 * Creates a GTK builder given the name of a GResource.
	 *
	 * The given `name` will automatically have
	 * `GREETER_RESOURCE_PREFIX` pre-pended to it.
	 */
	public Gtk.Builder create_builder(string name) {
		Gtk.Builder builder = new Gtk.Builder();
		try {
			builder.add_from_resource(GREETER_RESOURCE_PREFIX + name);
		} catch(GLib.Error error) {
			critical("Unable load GResource \"%s\" for Gtk.Builder: %s".printf(
					 name, error.message
					 ));
		}
		return builder;
	}

	/**
	 * Loads a GResource file as a string.
	 *
	 * The given `name` will automatically have
	 * `GREETER_RESOURCE_PREFIX` pre-pended to it.
	 */
	public string read_resource(string name) throws Error {
		InputStream input_stream = resources_open_stream(
			GREETER_RESOURCE_PREFIX + name,
			ResourceLookupFlags.NONE
			);
		DataInputStream data_stream = new DataInputStream(input_stream);
		size_t length;
		return data_stream.read_upto("\0", 1, out length);
	}

	public bool is_directory(File file) {
		return file.query_file_type(0) == FileType.DIRECTORY;
	}

	public void register_mimetypes() {
		if(mimetypes == null) {
			mimetypes = new Gee.TreeMap<string, string>();
			mimetypes.set("html", "text/html");
			mimetypes.set("js", "text/javascript");
			mimetypes.set("css", "text/css");
			mimetypes.set("png", "image/png");
			mimetypes.set("jpg", "image/jpg");
			mimetypes.set("jpeg", "image/jpeg");
      mimetypes.set("gif", "image/gif");
      mimetypes.set("mp4", "video/mp4");
      mimetypes.set("flv", "video/x-flv");
      mimetypes.set("webm", "video/webm");
			mimetypes.set("webp", "image/webp");
			mimetypes.set("svg", "image/svg+xml");
		}
	}

	public string get_mime_type(string name) {
		if(mimetypes == null) register_mimetypes();
		var ext = get_file_extension(name);
		return mimetypes.get(ext);
	}

	public bool is_html(string mime) {
		if(mime != null) {
			return mime == "text/html";
		}
		return false;
	}

	public bool is_javascript(string mime) {
		if(mime != null) {
			return mime == "text/javascript";
		}
		return false;
	}

	public bool is_css(string mime) {
		if(mime != null) {
			return mime == "text/css";
		}
		return false;
	}

	public bool is_image(string mime) {
		if(mime != null) {
			var regex = new Regex("(.*)/.*");
			var split = regex.split(mime);
			if(split.length > 0) {
				return split[1] == "image";
			}
		}
		return false;
	}

	public static bool is_font(string basename) {
		try {
			var regex = new Regex("\\.(ttf|woff|woff2|eot|svg)(\\?v.*)?$");
			string[] result = regex.split(basename);
			debug("is font file: %s", result[1]);
			return result.length > 1;
		} catch(Error e) {
			critical("invalid regex used : %s", e.message);
		}
		return false;
	}

	public static string? get_font_version(string basename) {
		try {
			var regex = new Regex("\\.(ttf|woff|woff2|eot|svg)(\\?v.*)?$");
			string[] result = regex.split(basename);
			debug("font version: %s", result[2]);
			return result[2];
		} catch(Error e) {
			critical("invalid regex used : %s", e.message);
		}
		return null;
	}

	public static string? get_file_extension(string basename) {
		debug("get_file_extension: %s", basename);
		try {
			// font file sometime have version behind the filename
			var regex = new Regex("\\.([0-9a-z]+)(\\?v=.*)?$");
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

	public static bool file_exists(string path) {
		return FileUtils.test(path, FileTest.EXISTS);
	}

	public static bool is_url_query(string path) {
		try {
			// we use url query for setting up background inside iframe
			var regex = new Regex("\\.(html)(\\?.*)?$");
			string[] result = regex.split(path);

			return result.length > 1;
		} catch(RegexError e) {
			critical("invalid regex used : %s", e.message);
		}
		return false;
	}

	public static string? get_url_query(string path) {
		try {
			var regex = new Regex("\\.(html)(\\?.*)?$");
			string[] result = regex.split(path);

			if(result.length > 1) {
				debug("url query: %s", result[2]);
				return result[2];
			}
		} catch(RegexError e) {
			critical("invalid regex used : %s", e.message);
		}
		return null;
	}
	public static File? get_real_file(string path) {
		message("get_real_file %s", path);
		if(is_font(path)) {
			var version = get_font_version(path);
			var realpath = path.replace(version, "");
			debug("file realpath %s", realpath);
			if(file_exists(realpath)) {
				message("sending font from %s", realpath);
				File file = File.new_for_path(realpath);
				return file;
			}
		} else {
			if(is_url_query(path)) {
				var q = get_url_query(path);
				var realpath = path.replace(q, "");
				if(file_exists(realpath)) {
					debug("sending html %s", realpath);
					File file = File.new_for_path(realpath);
					return file;
				}
			} else if(file_exists(path)) {
				File file = File.new_for_path(path);
				return file;
			}
		}
		return null;
	}
}
