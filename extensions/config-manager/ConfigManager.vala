using Gee;
using JS;
using Webkit2gtkGreeter.JSUtils;

namespace Webkit2gtkGreeter {

	public class ConfigManager : GLib.Object {

		public Gee.Map<string, Gee.TreeMap<string, string> > config;
		private Gee.Map<string, string> description; // allow optional commenting config entrys.
		public string used_config_path;
		unowned ClassDefinition cmgr_def;
		private static unowned JS.Object conf = null;
		public ConfigManager.with_path(string path) {

		}
		public ConfigManager() {

			this.config =  new Gee.TreeMap<string, Gee.TreeMap<string, string> >();

			//try to read/create config file on given array of paths
			string conffile2 = null;

			//1. Try to read conf file
			//  foreach(var path in paths) {
			//      string testfile = @"$(path)/$(conffile)";
			//      message(@"Search $(testfile)\n");
			//      if(search_config_file(testfile)) {
			//              conffile2 = testfile;
			//              message(@"Found $(testfile)\n");
			//              break;
			//      }
			//  }

			//2. Try deprecated name with leading dot
			//  if(conffile2 == null) {
			//      foreach(var path in paths) {
			//              string testfile = @"$(path)/.$(conffile)";
			//              debug(@"Search $(testfile)\n");
			//              if(search_config_file(testfile)) {
			//                      conffile2 = testfile;
			//                      debug(@"Found $(testfile)\n");
			//                      break;
			//              }
			//      }
			//  }

			//3. Try to write new conf file if read had failed
			//  if(conffile2 == null) {
			//      foreach(var path in paths) {
			//              string testfile = @"$(path)/$(conffile)";
			//              if(create_conf_file(testfile) > -1) {
			//                      debug(@"Create $(testfile)\n");
			//                      conffile2 = testfile;
			//                      break;
			//              }
			//      }
			//  }

			//  debug(@"Config file: $(conffile2)");

			//  if(search_config_file(conffile2))
			//      load_config_file(conffile2);

			//  add_intern_values();
			//  used_config_path = conffile2;
		}
		public static unowned JS.Object class_constructor_cb(Context ctx,
		                                                     JS.Object constructor,
		                                                     [CCode(array_length_pos = 3.9, array_length_type = "size_t")] JS.Value[] arguments,
		                                                     out JS.Value exception) {
			exception = null;
			message("ConfigManager constructor");
			return constructor;
		}
		public static void initialize_cb(Context context, JS.Object obj) {
			message("ConfigManager initialize");

			unowned JS.Object add_section_fun = context.make_function(new JS.String.with_utf8_c_string("addSection"), add_section);
			obj.set_property(context, new JS.String.with_utf8_c_string("addSection"), add_section_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object has_section_fun = context.make_function(new JS.String.with_utf8_c_string("hasSection"), has_section);
			obj.set_property(context, new JS.String.with_utf8_c_string("hasSection"), has_section_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object has_key_fun = context.make_function(new JS.String.with_utf8_c_string("hasKey"), has_key);
			obj.set_property(context, new JS.String.with_utf8_c_string("hasKey"), has_key_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object set_fun = context.make_function(new JS.String.with_utf8_c_string("set"), set);
			obj.set_property(context, new JS.String.with_utf8_c_string("set"), set_fun, JS.PropertyAttribute.ReadOnly);

		}

		public static void finalize_cb(JS.Object obj) {
			message("ConfigManager finalize");
		}

		public unowned JS.Object make_class(JS.Context context) {
			conf = context.make_object();

			cmgr_def = {
				0, // version
				JS.ClassAttribute.None, // attributes
				"ConfigManager", // className
				null, // parentClass
				null, // staticValues
				null, // staticFunctions
				initialize_cb, // initialize
				finalize_cb, // finalize
				null, // hasProperty
				null, // getProperty
				null, // setProperty
				null, // deleteProperty
				null, // getPropertyNames
				null, // callAsFunction
				class_constructor_cb, // callAsConstructor
				null, // hasInstance
				null // convertToType
			};
			unowned JS.Class cmgr_class = JS.create_class(cmgr_def);
			unowned JS.Object class_obj = context.make_object(cmgr_class);
			return class_obj;
		}

		public static unowned JS.Value add_section(JS.Context ctx,
		                                           JS.Object function,
		                                           JS.Object thisObject,
		                                           JS.Value[] args,
		                                           out unowned JS.Value exception) {
			message("add_section function called");
			exception = null;
			try {
				var section_variant = variant_from_value(ctx, args[0]);
				string section_name = section_variant.get_string();

				unowned JS.Value section = JSUtils.object_from_JSON(ctx, "{}");
				conf.set_property(ctx,
				                  new JS.String.with_utf8_c_string(section_name),
				                  section,
				                  JS.PropertyAttribute.ReadOnly);

			} catch(JSApiError e) {
				critical(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.undefined(ctx);
		}

		//  public void add_section(string name) {
		//      var section =  new Gee.TreeMap<string, string>();
		//      config.set(name, section);
		//  }
		public static unowned JS.Value has_section(JS.Context ctx,
		                                           JS.Object function,
		                                           JS.Object thisObject,
		                                           JS.Value[] args,
		                                           out unowned JS.Value exception) {
			exception = null;
			try{
				var section = variant_from_value(ctx, args[0]);
				message("has_section function called : %s", section.get_string());
				unowned JS.Value val = o_get_object(ctx, conf, section.get_string());
				bool result = !val.is_null(ctx) && !val.is_undefined(ctx);
				message("result : %s", result.to_string());
				return JS.Value.boolean(ctx, result);
			} catch(JSApiError e) {
				message(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.boolean(ctx, false);
		}
		//  public bool has_section(string name) {
		//      return config.has_key(name);
		//  }
		public static unowned JS.Value has_key(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			message("has_key function called ");
			exception = null;
			try {
				var section_variant = variant_from_value(ctx, args[0]);
				var key_variant = variant_from_value(ctx, args[1]);

				string key_name = key_variant.get_string();
				string section_name = section_variant.get_string();

				unowned JS.Object section = o_get_object(ctx, conf, section_name);
				if(section.is_null(ctx) || section.is_undefined(ctx) || !section.is_object(ctx)) {
					return JS.Value.boolean(ctx, false);
				}
				unowned JS.Value val = o_get_object(ctx, section, key_name);
				return JS.Value.boolean(ctx, !val.is_null(ctx) && !val.is_undefined(ctx));
			} catch(JSApiError e) {
				message(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.boolean(ctx, false);
		}
		//  public bool has_key(string section, string name) {


		//  return has_section(section) && config.get(section).has_key(name);
		//      return false;
		//  }

		public Gee.TreeMap<string, string> items(string section) {
			return config.get(section);
		}

		public Gee.Map<string, Gee.TreeMap<string, string> > getConfig() {
			return config;
		}

		public string[] sections() {
			string[] results = {};
			int i = 0;
			foreach(var str in config.keys) {
				results[i] = str;
				i++;
			}
			return results;
		}
		public static unowned JS.Value set(JS.Context ctx,
		                                   JS.Object function,
		                                   JS.Object thisObject,
		                                   JS.Value[] args,
		                                   out unowned JS.Value exception) {
			var section_variant = variant_from_value(ctx, args[0]);
			var key_variant = variant_from_value(ctx, args[1]);
			var value_variant = variant_from_value(ctx, args[2]);

			string key_name = key_variant.get_string();
			string section_name = section_variant.get_string();
			string val = value_variant.get_string();

			unowned JS.Object section = o_get_object(ctx, conf, section_name);
			section.set_property(ctx,
			                     new JS.String.with_utf8_c_string(key_name),
			                     section,
			                     JS.PropertyAttribute.ReadOnly);
			return JS.Value.undefined(ctx);
		}
		//  public void set(string section_name, string name, string value) {
		//      var section = config.get(section_name);
		//      section.set(name, value);
		//  }
		public static unowned JS.Value get(JS.Context ctx,
		                                   JS.Object function,
		                                   JS.Object thisObject,
		                                   JS.Value[] args,
		                                   out unowned JS.Value exception) {
			var section_variant = variant_from_value(ctx, args[0]);
			var key_variant = variant_from_value(ctx, args[1]);
			var value_variant = variant_from_value(ctx, args[2]);

			string key_name = key_variant.get_string();
			string section_name = section_variant.get_string();
			string val = value_variant.get_string();

			unowned JS.Object section = o_get_object(ctx, conf, section_name);
			if(section.is_null(ctx) || section.is_undefined(ctx)) {
				return JS.Value.undefined(ctx);
			}
			return section.get_property(ctx, new JS.String.with_utf8_c_string(key_name));
		}
		//  public string get(string section_name, string name) {
		//  	return get_string(section_name, name);
		//  }

		public string get_string(string section_name, string name) {
			var section = config.get(section_name);
			return section.get(name);

		}

		public int get_int(string section_name, string name) {
			var section = config.get(section_name);
			string val = section.get(name);
			var regex = new Regex("^-{0,1}\\d+$");
			if(regex.match(val)) {
				message("value is a valid number");
				return int.parse(val);
			}
			return 0;
		}

		public float get_float(string section_name, string name) {
			var section = config.get(section_name);
			string val = section.get(name);
			var regex = new Regex("^\\d+\\.\\d+$");
			if(regex.match(val)) {
				message("value is a valid number");
				return float.parse(val);
			}
			return 0;
		}

		public bool remove_section(string section_name) {
			config.unset(section_name);
			//  return !config.has_key(section_name);
			return false;
		}

		public bool remove_key(string section_name, string name) {
			var section = config.get(section_name);
			section.unset(name);
			//  return !section.has_key(section_name);
			return false;
		}
		//  private void addSetting(string name, string val, string? comment) {
		//      config.set(name, val);

		//      if(comment != null) {
		//              description.set(name, comment);
		//      }
		//  }

		/*
		         Standard values. This vaules will be written in the config file
		         if it was not found.
		 */
		//  public void add_defaults() {
		//      //config.set("show_shortcut", "<Mod4><Super_L>n", "Toggle the visibility of the window.");
		//      addSetting("show_shortcut", "<Ctrl><Alt>q", "Toggle the visibility of the window.");
		//      addSetting("on_top", "1", "Show window on top.");
		//      addSetting("position", "3", "Window position on startup (num pad orientation)");
		//      /* width of application window
		//               if value between 'resolution width'*max_width and  'resolution width'*min_width */
		//      addSetting("width", "1000", "Width in Pixel. Min_width and max_width bound sensible values. ");
		//      addSetting("min_width", "0.25", "Minimal width. 1=full screen width");
		//      addSetting("max_width", "0.5", "Maximal width. 1=full screen width");
		//      addSetting("move_shortcut", "<Ctrl><Alt>n", "Circle through window posisitions.");
		//      addSetting("position_cycle", "2 3 6 1 3 9 4 7 8", "List of positions (num pad orientation)\n# The n-th number marks the next position of the window.\n# To limit the used positions to screen corners use\n#position_cycle = 3 3 9 1 3 9 1 7 7");
		//      addSetting("display_numpad", "1", null);
		//      addSetting("display_function_keys", "0", null);
		//      addSetting("window_selectable", "0", "Disable window selection to use the program as virtual keyboard.");
		//      addSetting("window_decoration", "0", "Show window decoration/border (not recommended).");
		//      addSetting("screen_width", "auto", "Set the resolution of your screen manually, if the automatic detection fails.");
		//      addSetting("screen_height", "auto", "Set the resolution of your screen manually, if the automatic detection fails.");
		//      addSetting("show_on_startup", "1", "Show window on startup.");
		//      addSetting("asset_folder", "./assets", "Default lookup folder image data.");
		//  }

		/*
		         Enrich setting map by some values. User can not change them because
		         intern values overrides external values.
		 */
		//  private void add_intern_values() {
		//      config.set("numpad_width", "350");
		//      config.set("function_keys_height", "30");
		//  }

		public void read(string path) {

		}
		public void write(string path) {

		}
		private bool search_config_file(string conffile) {
			var file = File.new_for_path(conffile);
			return file.query_exists(null);
		}

		private int create_conf_file(string conffile) {
			//  var file = File.new_for_path(conffile);

			//  try {
			//      //Create a new file with this name
			//      var file_stream = file.create(FileCreateFlags.NONE);

			//      // Test for the existence of file
			//      if(!file.query_exists()) {
			//              stdout.printf("Can't create config file.\n");
			//              return -1;
			//      }

			//      // Write text data to file
			//      var data_stream = new DataOutputStream(file_stream);

			//      foreach(Gee.Map.Entry<string, string> e in this.config.entries) {

			//              if(this.description.has_key(e.key)) {
			//                      data_stream.put_string("# " + this.description.get(e.key) + "\n");
			//              }

			//              data_stream.put_string(e.key + " = " + e.value + "\n");
			//      }
			//  } // Streams
			//  catch(GLib.IOError e) { return -1; }
			//  catch(GLib.Error e) { return -1; }

			return 0;
		}

		private int load_config_file(string conffile) {

			// A reference to our file
			var file = File.new_for_path(conffile);

			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var in_stream = new DataInputStream(file.read(null));
				string line;
				string[] split;
				var section = new Regex("\\s*\\[([^\\]]+)]");
				var comment = new Regex("^#.*$");
				var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");
				Gee.TreeMap<string, string>? curSec = null;
				// Read lines until end of file (null) is reached
				while((line = in_stream.read_line(null, null)) != null) {

					if(comment.match(line)) continue;

					split = regex.split(line);
					var res = section.split(line);
					if(res.length > 1) {
						curSec = new Gee.TreeMap<string, string>();
						config.set(res[0].strip(), curSec);
					} else if(curSec == null) {
						throw new ConfigManagerException.MISSING_SECTION_HEADER("");
					} else {
						res = regex.split(line);
						if(res.length > 1) {
							var key = res[1];
							curSec[key] = res[2];
						} else {
							throw new ConfigManagerException.PARSE_ERROR("");
						}
					}
				}
			} catch(GLib.IOError e) {
				error("%s", e.message);
			} catch(RegexError e) {
				error("%s", e.message);
			} catch(GLib.Error e) {
				error("%s", e.message);
			}

			return 0;
		}


	} // end ConfigManager
	public errordomain ConfigManagerException {
		MISSING_SECTION_HEADER,
		PARSE_ERROR
	}
}
