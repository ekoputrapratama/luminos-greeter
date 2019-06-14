
using JS;
using Gee;
using Gtk;
using WebKit;
using LightDM;
using Luminos.JSUtils;
using Luminos.Utility;

namespace Luminos {
	private LightDM.Greeter lightdm_greeter;
	private unowned LightDM.UserList lightdm_user_list;
	private LightDMApi* instance = null;
	private bool destroy_instance = false;

	private static unowned JS.Value htmlbg_to_js_object(JS.Context ctx, string path) {
		var bgname = File.new_for_path(path).get_basename();
		var conf_path = path + Path.DIR_SEPARATOR_S + "index.bg";
		var conf = load_config_file(conf_path);
		var bg = conf.get("background");
		unowned JS.Object obj = ctx.make_object();


		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("name"),
		                 to_js_string(ctx, bg.get("name")),
		                 JS.PropertyAttribute.None);
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("webgl"),
		                 JS.Value.boolean(ctx, bool.parse(bg.get("webgl"))),
		                 JS.PropertyAttribute.None);
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("html"),
		                 JS.Value.boolean(ctx, true),
		                 JS.PropertyAttribute.None);
		string? image = null;
		if(bg.get("image") != null) {
			image = bg.get("image");
		} else if(bg.get("thumbnail") != null) {
			image = bg.get("thumbnail");
		}
		if(image != null) {
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("image"),
			                 JS.Value.boolean(ctx, bool.parse(bg.get("webgl"))),
			                 JS.PropertyAttribute.None);
		}

		var url = bg.get("url");
		bool is_absolute = Path.is_absolute(url);

		if(!is_absolute) {
			url = "backgrounds://" + bgname + Path.DIR_SEPARATOR_S + url;
		}

		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("url"),
		                 to_js_string(ctx, url),
		                 JS.PropertyAttribute.None);
		return obj;
	}
	private static unowned JS.Value bg_to_js_object(JS.Context ctx, string path) {
		unowned JS.Object obj = ctx.make_object();

		var filename = File.new_for_path(path).get_basename();
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("name"),
		                 to_js_string(ctx, filename),
		                 JS.PropertyAttribute.None);
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("webgl"),
		                 JS.Value.boolean(ctx, false),
		                 JS.PropertyAttribute.None);
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("html"),
		                 JS.Value.boolean(ctx, false),
		                 JS.PropertyAttribute.None);
		obj.set_property(ctx,
		                 new JS.String.with_utf8_c_string("image"),
		                 to_js_string(ctx, path),
		                 JS.PropertyAttribute.None);
		return obj;
	}
	// TODO : recursively scan folder and sub folder
	public static unowned JS.Value bglist(JS.Context ctx,
	                                      JS.Object function,
	                                      JS.Object thisObject,
	                                      JS.Value[] args,
	                                      out unowned JS.Value exception) {
		exception = null;
		ArrayList<string> accepted_images = new ArrayList<string>();
		accepted_images.add("png");
		accepted_images.add("gif");
		accepted_images.add("jpg");
		accepted_images.add("jpeg");

		try {
			var path = variant_from_value(ctx, args[0]).get_string();
			var dir = File.new_for_path(path);
			string[] folders = {};
			void*[] backgrounds = {};

			var enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);
			FileInfo info;
			while((info = enumerator.next_file()) != null) {
				var p = path + Path.DIR_SEPARATOR_S + info.get_name();
				if(is_directory_info(info)) {
					if(is_html_bg(p)) {
						backgrounds += htmlbg_to_js_object(ctx, p);
					} else {
						folders += p;
					}
				} else {
					var ext = get_file_extension(info.get_name());
					if(accepted_images.contains(ext)) {
						backgrounds += bg_to_js_object(ctx, p);
					}
				}
			}

			for(var i = 0; i < folders.length; i++) {
				path = folders[i];
				dir = File.new_for_path(path);
				enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);

				while((info = enumerator.next_file()) != null) {
					var p = path + Path.DIR_SEPARATOR_S + info.get_name();
					if(is_directory_info(info)) {
						if(is_html_bg(p)) {
							backgrounds += htmlbg_to_js_object(ctx, p);
						} else {
							folders += p;
						}
					} else {
						var ext = get_file_extension(info.get_name());
						if(accepted_images.contains(ext)) {
							backgrounds += bg_to_js_object(ctx, p);
						}
					}
				}
			}

			unowned JS.Object arr = ctx.make_array((JS.Value[])backgrounds, null);
			return arr;
		} catch(JSApiError e) {
			GLib.critical("Error when parsing arguments value to Variant : %s", e.message);
		} catch(Error e) {
			GLib.critical("Error when enumerating directory content : %s", e.message);
		}
		return JS.Value.undefined(ctx);
	}

	public static unowned JS.Value dirlist(JS.Context ctx,
	                                       JS.Object function,
	                                       JS.Object thisObject,
	                                       JS.Value[] args,
	                                       out unowned JS.Value exception) {

		exception = null;
		ArrayList<string> accepted_images = new ArrayList<string>();
		accepted_images.add("png");
		accepted_images.add("jpg");
		accepted_images.add("jpeg");
		try {
			var path = variant_from_value(ctx, args[0]).get_string();
			var dir = File.new_for_path(path);
			string[] folders = {};
			void*[] paths = {};

			var enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);
			FileInfo info;
			while((info = enumerator.next_file()) != null) {
				var p = path + Path.DIR_SEPARATOR_S + info.get_name();
				if(is_directory_info(info)) {
					folders += p;
				} else {
					var ext = get_file_extension(info.get_name());
					if(accepted_images.contains(ext)) {
						paths += JS.Value.string(ctx, new JS.String(p));
					}
				}
			}

			for(var i = 0; i < folders.length; i++) {
				path = folders[i];
				dir = File.new_for_path(path);
				enumerator = dir.enumerate_children(FileAttribute.STANDARD_NAME, 0);

				while((info = enumerator.next_file()) != null) {
					var p = path + Path.DIR_SEPARATOR_S + info.get_name();
					if(is_directory_info(info)) {
						folders += p;
					} else {
						paths += JS.Value.string(ctx, new JS.String(p));
					}
				}
			}

			unowned JS.Object arr = ctx.make_array((JS.Value[])paths, null);
			return arr;
		} catch(JSApiError e) {
			GLib.critical("Error when parsing arguments value to Variant : %s", e.message);
		} catch(Error e) {
			GLib.critical("Error when enumerating directory content : %s", e.message);
		}
		return JS.Value.undefined(ctx);
	}

	private void setup_global_functions(JS.Context context) {
		unowned JS.Object global = context.get_global_object();
		JS.Value exception;

		unowned JS.Value fun = global.get_property(context, new JS.String.with_utf8_c_string("dirlist"), out exception);
		if(is_null_or_undefined(context, fun)) {
			debug("adding dirlist function");
			unowned JS.Object dirlistFun = context.make_function(new JS.String.with_utf8_c_string("dirlist"), dirlist);
			global.set_property(context,
			                    new JS.String.with_utf8_c_string("dirlist"),
			                    dirlistFun,
			                    JS.PropertyAttribute.ReadOnly);
		}

		fun = global.get_property(context, new JS.String.with_utf8_c_string("bglist"), out exception);
		if(is_null_or_undefined(context, fun)) {
			debug("adding bglist function");
			unowned JS.Object bglistFun = context.make_function(new JS.String.with_utf8_c_string("bglist"), bglist);
			global.set_property(context,
			                    new JS.String.with_utf8_c_string("bglist"),
			                    bglistFun,
			                    JS.PropertyAttribute.ReadOnly);
		}
		fun = global.get_property(context, new JS.String.with_utf8_c_string("setShouldDestroyInstance"), out exception);
		if(is_null_or_undefined(context, fun)) {
			debug("adding shoulDestroyInstance function");
			unowned JS.Object shoulDestroyFun = context.make_function(new JS.String.with_utf8_c_string("setShouldDestroyInstance"), set_should_destroy_instance);
			global.set_property(context,
			                    new JS.String.with_utf8_c_string("setShouldDestroyInstance"),
			                    shoulDestroyFun,
			                    JS.PropertyAttribute.ReadOnly);
		}
	}

	private void setup_global_variables(JS.Context context) {
		debug("setup_global_variables");
		unowned JS.Object global = context.get_global_object();
		global.set_property(context,
		                    new JS.String.with_utf8_c_string("CONFIG_DIR"),
		                    to_js_string(context, Constants.CONF_DIR),
		                    JS.PropertyAttribute.ReadOnly);
		global.set_property(context,
		                    new JS.String.with_utf8_c_string("DATA_DIR"),
		                    to_js_string(context, Constants.DATA_DIR),
		                    JS.PropertyAttribute.ReadOnly);
		global.set_property(context,
		                    new JS.String.with_utf8_c_string("PACKAGE_NAME"),
		                    to_js_string(context, Constants.PACKAGE_NAME),
		                    JS.PropertyAttribute.ReadOnly);
		global.set_property(context,
		                    new JS.String.with_utf8_c_string("VERSION"),
		                    to_js_string(context, Constants.VERSION),
		                    JS.PropertyAttribute.ReadOnly);
		global.set_property(context,
		                    new JS.String.with_utf8_c_string("DIR_SEPARATOR"),
		                    to_js_string(context, Path.DIR_SEPARATOR_S),
		                    JS.PropertyAttribute.ReadOnly);
	}

	public void on_page_created(WebKit.WebExtension extension, WebKit.WebPage page) {
		debug("page-created");
		page.console_message_sent.connect(on_console_message);
	}

	private void on_console_message(WebKit.WebPage page,
	                                WebKit.ConsoleMessage message) {
		string source = message.get_source_id();
		debug("Console: [%s] %s %s:%u: %s",
		      message.get_level().to_string().substring("WEBKIT_CONSOLE_MESSAGE_LEVEL_".length),
		      message.get_source().to_string().substring("WEBKIT_CONSOLE_MESSAGE_SOURCE_".length),
		      source.length == 0 ? "unknown" : source,
		      message.get_line(),
		      message.get_text());
	}

	public static unowned JS.Value set_should_destroy_instance(JS.Context ctx,
	                                                           JS.Object function,
	                                                           JS.Object thisObject,
	                                                           JS.Value[] args,
	                                                           out unowned JS.Value exception) {
		destroy_instance = args[0].to_boolean(ctx);
		return JS.Value.undefined(ctx);
	}
	/**
	 *
	 * @return {void}
	 */
	private void authentication_complete() {
		GLib.message("authentication_complete");
		unowned JS.Context context = instance->context;
		unowned JS.Object global = context.get_global_object();
		unowned JS.Value lightdm_val = global.get_property(context, new JS.String("lightdm"));
		unowned JS.Object obj = lightdm_val.to_object(context);
		if(!is_defined(context, lightdm_val)) {
			GLib.critical("lightdm is not defined");
			return;
		}

		obj.set_property(context,
		                 new JS.String.with_utf8_c_string("authentication_user"),
		                 to_js_string(context, lightdm_greeter.authentication_user),
		                 JS.PropertyAttribute.None);
		obj.set_property(context,
		                 new JS.String.with_utf8_c_string("is_authenticated"),
		                 JS.Value.boolean(context, lightdm_greeter.is_authenticated),
		                 JS.PropertyAttribute.None);

		unowned JS.Value val = context.evaluate_script(new JS.String("typeof authentication_complete === 'function'"));
		bool isAntergosTheme = val.to_boolean(context);

		unowned JS.Value listener = obj.get_property(context, new JS.String("onAuthenticationComplete"));

		if(is_defined(context, listener)) {
			GLib.message("listener function is defined");
			void*[] params = {};
			unowned JS.Object fun = listener.to_object(context);
			if(fun.is_function(context)) {
				GLib.message("calling onAuthenticationComplete()");
				fun.call_as_function(context, fun, (JS.Value[]) params, null);
			} else {
				GLib.message("listener object is not a function");
			}
		} else {
			GLib.message("listener function is not defined");
		}

		// compatibility with antergos web-greeter
		if(isAntergosTheme) {
			GLib.message("calling compatibility function");
			JS.String script = new JS.String("authentication_complete();");
			context.evaluate_script(script);
		}
	}
	public void on_window_object_cleared(ScriptWorld world, WebPage page, WebKit.Frame frame) {
		debug("window object cleared");
		unowned JS.Context context = (JS.GlobalContext)frame.get_javascript_global_context();

		setup_global_variables(context);
		setup_global_functions(context);
		// we only keep 1 instance to prevent iframe load the lightdm object
		if(instance == null || destroy_instance) {
			if(destroy_instance && instance != null) {
				delete instance;
			}
			instance = new LightDMApi(context, lightdm_greeter, lightdm_user_list);
			instance->create_lightdm_object();
			destroy_instance = false;
		}
	}

	[CCode(cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
	public void webkit_web_extension_initialize(WebKit.WebExtension extension) {
		GLib.debug("core extension initialization");

		extension.page_created.connect(on_page_created);
		var scriptWorld = WebKit.ScriptWorld.get_default();
		scriptWorld.window_object_cleared.connect(on_window_object_cleared);

		lightdm_greeter = new LightDM.Greeter();
		lightdm_user_list = LightDM.UserList.get_instance();
		lightdm_greeter.authentication_complete.connect(authentication_complete);

		var connected = false;
		try {
			connected = lightdm_greeter.connect_to_daemon_sync();
		} catch(Error e) {
			warning("Failed to connect to LightDM daemon: %s", e.message);
		}

		if(!connected)
			Posix.exit(Posix.EXIT_FAILURE);


	}
}
