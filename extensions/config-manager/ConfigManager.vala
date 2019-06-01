using Gee;
using JS;
using Webkit2gtkGreeter.JSUtils;

namespace Webkit2gtkGreeter {

	public class ConfigManager : GLib.Object {

		private Gee.Map<string, string> description; // allow optional commenting config entrys.
		public string used_config_path;
		unowned ClassDefinition cmgr_def;
		private static unowned JS.Object? conf = null;
		unowned JS.Context context = null;

		public ConfigManager.with_path(string path) {

		}
		public ConfigManager.with_js_context(unowned JS.Context ctx) {
			context = ctx;
		}
		public ConfigManager() {

		}
		public static unowned JS.Object class_constructor_cb(Context ctx,
		                                                     JS.Object constructor,
		                                                     [CCode(array_length_pos = 3.9, array_length_type = "size_t")] JS.Value[] arguments,
		                                                     out JS.Value exception) {
			exception = null;
			return constructor;
		}
		public static void initialize_cb(Context context, JS.Object obj) {
			debug("ConfigManager initialize");

			unowned JS.Object add_section_fun = context.make_function(new JS.String.with_utf8_c_string("addSection"), add_section);
			obj.set_property(context, new JS.String.with_utf8_c_string("addSection"), add_section_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object has_section_fun = context.make_function(new JS.String.with_utf8_c_string("hasSection"), has_section);
			obj.set_property(context, new JS.String.with_utf8_c_string("hasSection"), has_section_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object has_key_fun = context.make_function(new JS.String.with_utf8_c_string("hasKey"), has_key);
			obj.set_property(context, new JS.String.with_utf8_c_string("hasKey"), has_key_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object set_fun = context.make_function(new JS.String.with_utf8_c_string("set"), set);
			obj.set_property(context, new JS.String.with_utf8_c_string("set"), set_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object get_fun = context.make_function(new JS.String.with_utf8_c_string("get"), get);
			obj.set_property(context, new JS.String.with_utf8_c_string("get"), get_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object items_fun = context.make_function(new JS.String.with_utf8_c_string("items"), items);
			obj.set_property(context, new JS.String.with_utf8_c_string("items"), items_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object sections_fun = context.make_function(new JS.String.with_utf8_c_string("sections"), sections);
			obj.set_property(context, new JS.String.with_utf8_c_string("sections"), sections_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object remove_section_fun = context.make_function(new JS.String.with_utf8_c_string("removeSection"), remove_section);
			obj.set_property(context, new JS.String.with_utf8_c_string("removeSection"), remove_section_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object remove_key_fun = context.make_function(new JS.String.with_utf8_c_string("removeKey"), remove_key);
			obj.set_property(context, new JS.String.with_utf8_c_string("removeKey"), remove_key_fun, JS.PropertyAttribute.ReadOnly);

			//  unowned JS.Object load_file_fun = context.make_function(new JS.String.with_utf8_c_string("loadFile"), load_file);
			//  obj.set_property(context, new JS.String.with_utf8_c_string("loadFile"), load_file_fun, JS.PropertyAttribute.ReadOnly);

			unowned JS.Object read_fun = context.make_function(new JS.String.with_utf8_c_string("read"), read);
			obj.set_property(context, new JS.String.with_utf8_c_string("read"), read_fun, JS.PropertyAttribute.ReadOnly);
		}

		public static void finalize_cb(JS.Object obj) {
			debug("ConfigManager finalize");
		}

		public unowned JS.Object make_class() {
			conf = this.context.make_object();

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
			unowned JS.Object class_obj = this.context.make_object(cmgr_class);
			return class_obj;
		}

		public static unowned JS.Value add_section(JS.Context ctx,
		                                           JS.Object function,
		                                           JS.Object thisObject,
		                                           JS.Value[] args,
		                                           out unowned JS.Value? exception) {
			debug("add_section function called");
			exception = null;
			try {
				var section_variant = variant_from_value(ctx, args[0]);
				string section_name = section_variant.get_string();

				unowned JS.Value section = JSUtils.object_from_JSON(ctx, "{}");
				conf.set_property(ctx,
				                  new JS.String.with_utf8_c_string(section_name),
				                  section,
				                  JS.PropertyAttribute.None);

			} catch(JSApiError e) {
				critical(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value has_section(JS.Context ctx,
		                                           JS.Object function,
		                                           JS.Object thisObject,
		                                           JS.Value[] args,
		                                           out unowned JS.Value? exception) {
			exception = null;
			try{
				var section = variant_from_value(ctx, args[0]);
				debug("has_section function called : %s", section.get_string());
				unowned JS.Value val = o_get_object(ctx, conf, section.get_string());
				bool result = !val.is_null(ctx) && !val.is_undefined(ctx);
				debug("result : %s", result.to_string());
				return JS.Value.boolean(ctx, result);
			} catch(JSApiError e) {
				error(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.boolean(ctx, false);
		}



		public static unowned JS.Value has_key(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value? exception) {
			debug("has_key function called ");
			exception = null;
			try {
				var section_variant = variant_from_value(ctx, args[0]);
				var key_variant = variant_from_value(ctx, args[1]);

				string key_name = key_variant.get_string();
				string section_name = section_variant.get_string();
				debug("key_name=%s", key_name);

				unowned JS.Object section = o_get_object(ctx, conf, section_name);
				if(section.is_null(ctx) || section.is_undefined(ctx) || !section.is_object(ctx)) {
					debug("section is invalid");
					return JS.Value.boolean(ctx, false);
				}
				unowned JS.Value val = section.get_property(ctx, new JS.String.with_utf8_c_string(key_name));
				bool result = !val.is_null(ctx) && !val.is_undefined(ctx);
				debug("has_key result : %s", result.to_string());
				return JS.Value.boolean(ctx, result);
			} catch(JSApiError e) {
				critical(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
			}
			return JS.Value.boolean(ctx, false);
		}

		public static unowned JS.Value items(JS.Context ctx,
		                                     JS.Object function,
		                                     JS.Object thisObject,
		                                     JS.Value[] args,
		                                     out unowned JS.Value exception) {
			return conf.get_property(ctx, (JS.String)args[0]);
		}

		public static unowned JS.Value sections(JS.Context ctx,
		                                        JS.Object function,
		                                        JS.Object thisObject,
		                                        JS.Value[] args,
		                                        out unowned JS.Value exception) {

			return get_js_property_names(ctx, conf);
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
			                     args[2],
			                     JS.PropertyAttribute.None);
			return JS.Value.undefined(ctx);
		}

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

		//  public string get_string(string section_name, string name) {
		//  	var section = config.get(section_name);
		//  	return section.get(name);

		//  }

		//  public int get_int(string section_name, string name) {
		//  	var section = config.get(section_name);
		//  	string val = section.get(name);
		//  	var regex = new Regex("^-{0,1}\\d+$");
		//  	if(regex.match(val)) {
		//  		message("value is a valid number");
		//  		return int.parse(val);
		//  	}
		//  	return 0;
		//  }

		//  public float get_float(string section_name, string name) {
		//  	var section = config.get(section_name);
		//  	string val = section.get(name);
		//  	var regex = new Regex("^\\d+\\.\\d+$");
		//  	if(regex.match(val)) {
		//  		message("value is a valid number");
		//  		return float.parse(val);
		//  	}
		//  	return 0;
		//  }
		public static unowned JS.Value remove_section(JS.Context ctx,
		                                              JS.Object function,
		                                              JS.Object thisObject,
		                                              JS.Value[] args,
		                                              out unowned JS.Value exception) {
			var section_name = variant_from_value(ctx, args[0]).get_string();
			conf = remove_property(ctx, conf, section_name);
			return JS.Value.boolean(ctx, !has_property(ctx, conf, section_name));
		}

		public static unowned JS.Value remove_key(JS.Context ctx,
		                                          JS.Object function,
		                                          JS.Object thisObject,
		                                          JS.Value[] args,
		                                          out unowned JS.Value exception) {
			debug("remove_key function called");
			var section_name = variant_from_value(ctx, args[0]).get_string();
			var key_name = variant_from_value(ctx, args[1]).get_string();

			unowned JS.Object section = o_get_object(ctx, conf, section_name);
			section = remove_property(ctx, section, key_name);
			conf.set_property(ctx, new JS.String(section_name), section);
			return JS.Value.boolean(ctx, !has_property(ctx, section, key_name));
		}

		private static string get_file_extension(string basename) {
			debug("get_file_extension: %s", basename);
			var regex = new Regex("\\.([0-9a-z]+)$");
			string[] result = regex.split(basename);
			if(result.length > 1) {
				debug("file extension: %s", result[1]);
				return result[1];
			}
			return null;
		}

		public static unowned JS.Value read(JS.Context ctx,
		                                    JS.Object function,
		                                    JS.Object thisObject,
		                                    JS.Value[] args,
		                                    out unowned JS.Value exception) {
			var path = variant_from_value(ctx, args[0]).get_string();
			var file = File.new_for_path(path);
			if(file.query_exists()) {
				var extension = get_file_extension(file.get_basename());
				if(extension == "json") {
					var text = new StringBuilder();
					try {
						var dis = new DataInputStream(file.read());
						string line = null;
						while((line = dis.read_line(null, null)) != null) {
							text.append(line);
							text.append_c('\n');
						}
					} catch(Error e) {
						error(e.message);
					}
					unowned JS.Value cfg = object_from_JSON(ctx, text.str);
					conf = cfg.to_object(ctx, exception);
					return cfg;
				} else if(extension == "conf") {
					unowned JS.Object config = ctx.make_object();
					try {
						// Open file for reading and wrap returned FileInputStream into a
						// DataInputStream, so we can read line by line

						var in_stream = new DataInputStream(file.read(null));
						string line;
						string[] split;
						var section = new Regex("^\\[([^\\]]+)]$");
						var comment = new Regex("^#.*$");
						var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");
						unowned JS.Object curSec = null;
						string section_name = null;
						// Read lines until end of file (null) is reached
						while((line = in_stream.read_line(null, null)) != null) {
							if(comment.match(line) || line.length == 0) {
								continue;
							}

							split = regex.split(line);
							var res = section.split(line);
							if(res.length > 1) {
								section_name = res[1];
								curSec = ctx.make_object();
								config.set_property(ctx, new JS.String(res[1]), curSec);
							} else if(curSec == null) {
								throw new ConfigManagerException.MISSING_SECTION_HEADER("");
							} else {
								res = regex.split(line);
								if(res.length > 1) {
									var key = res[1];
									curSec.set_property(ctx, new JS.String(key), JS.Value.string(ctx, new JS.String(res[2])));
								} else {
									error("parse error");
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
					conf = config;
					return config;
				}
			} else {
				debug("file doesn't exists");
			}

			return JS.Value.undefined(ctx);
		}

		public unowned JS.Value write(JS.Context ctx,
		                              JS.Object function,
		                              JS.Object thisObject,
		                              JS.Value[] args,
		                              out unowned JS.Value exception) {

			var path = variant_from_value(ctx, args[0]).get_string();
			var file = File.new_for_path(path);
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
			return JS.Value.undefined(ctx);
		}

		private bool search_config_file(string conffile) {
			var file = File.new_for_path(conffile);
			return file.query_exists(null);
		}


		public static unowned JS.Value load_file(JS.Context ctx,
		                                         JS.Object function,
		                                         JS.Object thisObject,
		                                         JS.Value[] args,
		                                         out unowned JS.Value exception) {
			var path = variant_from_value(ctx, args[0]).get_string();
			// A reference to our file
			var file = File.new_for_path(path);
			unowned JS.Object config = ctx.make_object();
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line

				var in_stream = new DataInputStream(file.read(null));
				string line;
				string[] split;
				var section = new Regex("^\\[([^\\]]+)]$");
				var comment = new Regex("^#.*$");
				var regex = new Regex("\\s*(.*?)\\s*[=:]\\s*(.*)");
				unowned JS.Object curSec = null;
				string section_name = null;
				// Read lines until end of file (null) is reached
				while((line = in_stream.read_line(null, null)) != null) {
					if(comment.match(line) || line.length == 0) {
						continue;
					}

					split = regex.split(line);
					var res = section.split(line);
					if(res.length > 1) {
						if(curSec != null && section_name != null) {

						}
						section_name = res[1];
						curSec = ctx.make_object();
						config.set_property(ctx, new JS.String(res[1]), curSec);
					} else if(curSec == null) {
						throw new ConfigManagerException.MISSING_SECTION_HEADER("");
					} else {
						res = regex.split(line);
						if(res.length > 1) {
							var key = res[1];
							curSec.set_property(ctx, new JS.String(key), JS.Value.string(ctx, new JS.String(res[2])));
						} else {
							error("parse error");
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
			return config;
		}


	} // end ConfigManager

	public errordomain ConfigManagerException {
		MISSING_SECTION_HEADER,
		PARSE_ERROR
	}
}
