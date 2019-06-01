namespace Webkit2gtkGreeter {
	public struct DesktopEntry {
		public string name;
		public string comment;
		public string exec;
		public string try_exec;
	}
	class DesktopFileReader : GLib.Object {

		public DesktopFileReader() {

		}

		public DesktopEntry load_file(string path) {
			var file = File.new_for_path(path);
			DesktopEntry entry = {};
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var in_stream = new DataInputStream(file.read(null));
				string line;
				var comment = new Regex("^#.*$");
				var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");

				// Read lines until end of file (null) is reached
				while((line = in_stream.read_line(null, null)) != null) {
					if(comment.match(line)) continue;

					var res = regex.split(line);
					if(res.length > 1) {
						var key = res[1];
						switch(key) {
						case "Name":
							entry.name = res[2];
							break;
						case "Exec":
							entry.exec = res[2];
							break;
						case "TryExec":
							entry.try_exec = res[2];
							break;
						case "Comment":
							entry.comment = res[2];
							break;
						default:
							break;
						}

					} else {
						//  throw new Error("");
					}
				}
			} catch(GLib.IOError e) {
				error("%s", e.message);
			} catch(RegexError e) {
				error("%s", e.message);
			} catch(GLib.Error e) {
				error("%s", e.message);
			}

			return entry;
		}

		private unowned JS.Value to_js_string(JS.Context ctx, string val) {
			return JS.Value.string(ctx, new JS.String(val));
		}

		public unowned JS.Object to_js_object(JS.Context ctx, DesktopEntry entry) {
			unowned JS.Object obj = ctx.make_object();
			obj.set_property(ctx, new JS.String("name"), to_js_string(ctx, entry.name));
			obj.set_property(ctx, new JS.String("key"), to_js_string(ctx, entry.name));
			obj.set_property(ctx, new JS.String("comment"), to_js_string(ctx, entry.comment));
			return obj;
		}
	}
}
