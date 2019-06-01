using WebKit;
using JS;
using GLib;
using Gtk;
using Webkit2gtkGreeter.JSUtils;
using LightDM;
using Gee;

namespace Webkit2gtkGreeter {
	JSApi jsapi = null;
	private LightDM.Greeter lightdm_greeter;
	private unowned LightDM.UserList lightdm_user_list;
	public bool test_mode = false;
	private unowned JS.Object? lightdm_obj;

	public class JSApi : GLib.Object {
		public signal void on_string_callback();
		private DesktopFileReader desktop_reader;
		private unowned JS.Context? context = null;

		construct {

		}
		public JSApi() {
			lightdm_greeter = new LightDM.Greeter();
			lightdm_user_list = LightDM.UserList.get_instance();
			desktop_reader = new DesktopFileReader();

			lightdm_greeter.show_message.connect(show_message);
			lightdm_greeter.show_prompt.connect(show_prompt);

			lightdm_greeter.authentication_complete.connect(authentication_complete);

			lightdm_greeter.notify["has-guest-account-hint"].connect(() => {
				//  if (lightdm_greeter.has_guest_account_hint && guest_login_button.parent == null) {
				//      extra_login_grid.attach (guest_login_button, 0, 0);
				//      guest_login_button.show ();
				//  }
			});

			lightdm_greeter.notify["show-manual-login-hint"].connect(() => {
				//  if (lightdm_greeter.show_manual_login_hint && manual_login_button.parent == null) {
				//      extra_login_grid.attach (manual_login_button, 1, 0);
				//      manual_login_button.show ();
				//  }
			});
			var connected = false;
			try {
				connected = lightdm_greeter.connect_to_daemon_sync();
			} catch(Error e) {
				warning("Failed to connect to LightDM daemon: %s", e.message);
			}

			if(!connected && !test_mode)
				Posix.exit(Posix.EXIT_FAILURE);
		}

		private void authentication_complete() {
			debug("authentication_complete");
			unowned JS.Object global = this.context.get_global_object();
			unowned JS.Value lighdm_val = global.get_property(context, new JS.String("lightdm"));
			unowned JS.Object obj = lighdm_val.to_object(context, null);

			obj.set_property(context,
			                 new JS.String.with_utf8_c_string("authentication_user"),
			                 to_js_string(context, lightdm_greeter.authentication_user),
			                 JS.PropertyAttribute.None);
			obj.set_property(context,
			                 new JS.String.with_utf8_c_string("is_authenticated"),
			                 JS.Value.boolean(context, lightdm_greeter.is_authenticated),
			                 JS.PropertyAttribute.None);


			unowned JS.Value val = obj.get_property(context, new JS.String("onAuthenticationComplete"));
			if(!is_null_or_undefined(context, val)) {
				debug("listener function is defined");
				void*[] params = {};
				unowned JS.Object fun = val.to_object(context);
				if(fun.is_function(context)) {
					fun.call_as_function(context, fun, (JS.Value[]) params, null);
				}
			} else {
				debug("listener function is not defined");
			}

			// compatibility with antergos web-greeter
			JS.String script = new JS.String("if(typeof authentication_complete == 'function') authentication_complete();");
			context.evaluate_script(script);
		}

		private void show_message(string text, LightDM.MessageType type) {
			critical("message: `%s' (%d)", text, type);
			JS.String script = new JS.String("if(typeof show_message === 'function') show_message('" + text + "');");
			context.evaluate_script(script);
			/*var messagetext = string_to_messagetext(text);
			   if (messagetext == MessageText.FPRINT_SWIPE || messagetext == MessageText.FPRINT_PLACE) {
			    // For the fprint module, there is no prompt message from PAM.
			    send_prompt (PromptType.FPRINT);
			   }
			   current_login.show_message (type, messagetext, text);*/
		}
		public string? get_default_session()
		{
			var sessions = new GLib.List<string> ();
			sessions.append("cinnamon");
			sessions.append("mate");
			sessions.append("xfce");
			sessions.append("plasma");
			sessions.append("kde-plasma");
			sessions.append("kde");
			sessions.append("budgie-desktop");
			sessions.append("gnome");
			sessions.append("LXDE");
			sessions.append("lxqt");
			sessions.append("pekwm");
			sessions.append("pantheon");
			sessions.append("i3");
			sessions.append("enlightenment");
			sessions.append("deepin");
			sessions.append("openbox");
			sessions.append("awesome");
			sessions.append("gnome-xorg");
			sessions.append("ubuntu-xorg");

			foreach(string session in sessions) {
				var path = Path.build_filename("/usr/share/xsessions/", session.concat(".desktop"), null);
				if(FileUtils.test(path, FileTest.EXISTS)) {
					return session;
				}
			}

			warning("Could not find a default session.");
			return null;
		}
		public string validate_session(string? session)
		{
			/* Make sure the given session actually exists. Return it if it does.
			   otherwise, return the default session. */
			if(session != null) {
				var path = Path.build_filename("/usr/share/xsessions/", session.concat(".desktop"), null);
				if(!FileUtils.test(path, FileTest.EXISTS)) {
					debug("Invalid session: '%s'", session);
					session = null;
				}
			}

			if(session == null) {
				var default_session = get_default_session();
				debug("Using default session: '%s'", default_session);
				return default_session;
			}

			return session;
		}

		private void show_prompt(string text, LightDM.PromptType type = LightDM.PromptType.QUESTION) {
			critical("prompt: `%s' (%d)", text, type);
			/*send_prompt (lightdm_prompttype_to_prompttype(type), string_to_prompttext(text), text);
			   had_prompt = true;
			   current_login.show_prompt (type, prompttext, text);*/
			//  if (current_card is ManualCard) {
			//    if (type == LightDM.PromptType.SECRET) {
			//        ((ManualCard) current_card).ask_password ();
			//    } else {
			//        ((ManualCard) current_card).wrong_username ();
			//    }
			//  }
		}

		public void on_page_created(WebKit.WebExtension extension, WebKit.WebPage page) {
			debug("page-created");
		}

		public void on_window_object_cleared(ScriptWorld world, WebPage page, WebKit.Frame frame) {
			debug("window object cleared");
			unowned JS.Context context = (JS.GlobalContext)frame.get_javascript_context_for_script_world(world);

			this.context = context;

			setup_global_variables(context);
			setup_lightdm_object(context);
		}

		private void setup_global_variables(unowned JS.Context context) {
			debug("setup_global_variables");

			unowned JS.Object global = context.get_global_object();
			JS.Value? exception;

			global.set_property(context,
			                    new JS.String.with_utf8_c_string("CONFIG_DIR"),
			                    to_js_string(context, Constants.CONF_DIR),
			                    JS.PropertyAttribute.ReadOnly);
		}

		private void setup_lightdm_object(JS.Context context) {
			debug("setup_lightdm_object");
			unowned JS.Object global = context.get_global_object();
			JS.Value exception;
			unowned JS.Value lighdm_val = global.get_property(context, new JS.String("lightdm"));
			unowned JS.Object obj;

			if(is_null_or_undefined(context, lighdm_val)) {
				obj = context.make_object();
			} else {
				obj = lighdm_val.to_object(context, null);
			}

			unowned JS.Value sv = load_sessions(context);
			unowned JS.Object sessions = null;

			if(sv.is_object(context)) {
				sessions = sv.to_object(context);
			}

			if(sessions != null && !is_null_or_undefined(context, sessions)) {
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("sessions"),
				                 sessions,
				                 JS.PropertyAttribute.None);
			}

			unowned JS.Value uv = load_users(context);
			unowned JS.Object users = null;

			if(uv.is_object(context)) {
				users = uv.to_object(context);
			}

			if(users != null && !is_null_or_undefined(context, users)) {
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("users"),
				                 users,
				                 JS.PropertyAttribute.None);
			}

			setup_lightdm_functions(context, obj, out exception);
			setup_lightdm_variables(context, obj, out exception);

			global.set_property(context,
			                    new JS.String.with_utf8_c_string("lightdm"),
			                    obj,
			                    JS.PropertyAttribute.ReadOnly);
		}

		private unowned JS.Value language_to_object(JS.Context ctx, LightDM.Language language) {
			unowned JS.Object lang = ctx.make_object();
			lang.set_property(ctx,
			                  new JS.String.with_utf8_c_string("code"),
			                  to_js_string(ctx, language.code),
			                  JS.PropertyAttribute.None);
			lang.set_property(ctx,
			                  new JS.String.with_utf8_c_string("name"),
			                  to_js_string(ctx, language.name),
			                  JS.PropertyAttribute.None);
			lang.set_property(ctx,
			                  new JS.String.with_utf8_c_string("territory"),
			                  to_js_string(ctx, language.territory),
			                  JS.PropertyAttribute.None);
			return lang;
		}

		private void setup_lightdm_variables(JS.Context ctx, unowned JS.Object obj, out JS.Value exception = null) {
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("can_hibernate"),
			                 JS.Value.boolean(ctx, LightDM.get_can_hibernate()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("can_suspend"),
			                 JS.Value.boolean(ctx, LightDM.get_can_suspend()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("can_restart"),
			                 JS.Value.boolean(ctx, LightDM.get_can_restart()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("can_shutdown"),
			                 JS.Value.boolean(ctx, LightDM.get_can_shutdown()),
			                 JS.PropertyAttribute.None);

			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("is_authenticated"),
			                 JS.Value.boolean(ctx, lightdm_greeter.get_is_authenticated()),
			                 JS.PropertyAttribute.None);

			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("hostname"),
			                 to_js_string(ctx, LightDM.get_hostname()),
			                 JS.PropertyAttribute.None);

			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("in_authentication"),
			                 JS.Value.boolean(ctx, lightdm_greeter.in_authentication),
			                 JS.PropertyAttribute.None);

			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("default_language"),
			                 language_to_object(ctx, LightDM.get_language()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("default_session"),
			                 to_js_string(ctx, lightdm_greeter.get_default_session_hint()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("authentication_user"),
			                 to_js_string(ctx, lightdm_greeter.get_authentication_user()),
			                 JS.PropertyAttribute.None);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("num_users"),
			                 JS.Value.number(ctx, lightdm_user_list.length),
			                 JS.PropertyAttribute.None);

			unowned GLib.List<LightDM.Language> languages = LightDM.get_languages();
			void*[] temp = {};
			languages.foreach((language) => {
				temp += (void*)language_to_object(ctx, language);
			});

			unowned JS.Object arr = ctx.make_array((JS.Value[])temp, out exception);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("languages"),
			                 arr,
			                 JS.PropertyAttribute.None);

		}

		private void setup_lightdm_functions(JS.Context context, unowned JS.Object obj, out JS.Value exception = null) {
			unowned JS.Value fun = obj.get_property(context, new JS.String.with_utf8_c_string("restart"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding restart function");
				unowned JS.Object restartFun = context.make_function(new JS.String.with_utf8_c_string("restart"), restart);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("restart"),
				                 restartFun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("hibernate"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding hibernate function");
				unowned JS.Object hibernateFun = context.make_function(new JS.String.with_utf8_c_string("hibernate"), hibernate);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("hibernate"),
				                 hibernateFun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("shutdown"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding shutdown function");
				unowned JS.Object shutdownFun = context.make_function(new JS.String.with_utf8_c_string("shutdown"), shutdown);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("shutdown"),
				                 shutdownFun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("suspend"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding suspend function");
				unowned JS.Object suspendFun = context.make_function(new JS.String.with_utf8_c_string("suspend"), suspend);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("suspend"),
				                 suspendFun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("start_authentication"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding start_authentication function");
				unowned JS.Object start_auth_fun = context.make_function(new JS.String.with_utf8_c_string("start_authentication"), start_authentication);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("start_authentication"),
				                 start_auth_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("cancel_authentication"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding cancel_authentication function");
				unowned JS.Object cancel_auth_fun = context.make_function(new JS.String.with_utf8_c_string("cancel_authentication"), cancel_authentication);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("cancel_authentication"),
				                 cancel_auth_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("login"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding login function");
				unowned JS.Object login_fun = context.make_function(new JS.String.with_utf8_c_string("login"), login);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("login"),
				                 login_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("provide_secret"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding provide_secret function");
				unowned JS.Object provide_secret_fun = context.make_function(new JS.String.with_utf8_c_string("provide_secret"), provide_secret);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("provide_secret"),
				                 provide_secret_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}
		}

		public static unowned JS.Value provide_secret(JS.Context ctx,
		                                              JS.Object function,
		                                              JS.Object thisObject,
		                                              JS.Value[] args,
		                                              out unowned JS.Value exception) {
			var password = variant_from_value(ctx, args[0]).get_string();
			if(password != null) {
				try {
					debug("respond password to lightdm");
					lightdm_greeter.respond(password);
				} catch(Error e) {
					critical(e.message);
				}
			}
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Object session_to_js_object(JS.Context ctx, LightDM.Session session) {
			unowned JS.Object obj = ctx.make_object();
			obj.set_property(ctx, new JS.String("name"), to_js_string(ctx, session.name));
			obj.set_property(ctx, new JS.String("key"), to_js_string(ctx, session.key));
			obj.set_property(ctx, new JS.String("comment"), to_js_string(ctx, session.comment));
			return obj;
		}

		public unowned JS.Value load_sessions(JS.Context ctx) {
			debug("build_sessions");
			JS.Value? exception;

			void*[] params = {};
			foreach(LightDM.Session s in LightDM.get_sessions()) {
				debug("session : %s\n", s.name);
				params += (void*)session_to_js_object(ctx, s);
			}

			unowned JS.Object arr = ctx.make_array((JS.Value[]) params, out exception);
			if(exception != null) {
				error(exception_to_string(ctx, exception));
			}
			return arr;
		}

		private static unowned JS.Object user_to_js_object(JS.Context ctx, LightDM.User user) {
			unowned JS.Object obj = ctx.make_object();
			obj.set_property(ctx, new JS.String("display_name"), to_js_string(ctx, user.display_name));
			obj.set_property(ctx, new JS.String("name"), to_js_string(ctx, user.name));
			obj.set_property(ctx, new JS.String("session"), to_js_string(ctx, user.session));
			return obj;
		}

		private unowned JS.Value load_users(JS.Context ctx) {
			void*[] params = {};
			JS.Value? exception;

			if(lightdm_user_list.length > 0) {
				unowned GLib.List<LightDM.User> users = lightdm_user_list.users;
				users.foreach((user) => {
					debug("user : %s\n", user.name);
					params += (void*)user_to_js_object(ctx, user);
				});

				unowned string? select_user = lightdm_greeter.select_user_hint;
				var user_to_select = (select_user != null) ? select_user : null;

				bool user_selected = false;
				if(user_to_select != null) {
					//  user_cards.head.foreach((card) => {
					//      if(card.lightdm_user.name == user_to_select) {
					//              switch_to_card(card);
					//              user_selected = true;
					//      }
					//  });
				}

				if(!user_selected) {
					//  unowned Greeter.UserCard user_card = (Greeter.UserCard)user_cards.peek_head();
					//  user_card.show_input = true;
					//  try {
					//      lightdm_greeter.authenticate(user_card.lightdm_user.name);
					//  } catch(Error e) {
					//      critical(e.message);
					//  }
				}

				unowned JS.Object arr = ctx.make_array((JS.Value[]) params, out exception);
				return arr;
			} else {
				/* We're not certain that scaling factor will change, but try to wait for GSD in case it does */
				//  Timeout.add(500, () => {
				//      try {
				//              var initial_setup = AppInfo.create_from_commandline("io.elementary.initial-setup", null, GLib.AppInfoCreateFlags.NONE);
				//              initial_setup.launch(null, null);
				//      } catch(Error e) {
				//              string error_text = _("Unable to Launch Initial Setup");
				//              critical("%s: %s", error_text, e.message);

				//              var error_dialog = new Granite.MessageDialog.with_image_from_icon_name(
				//                      error_text,
				//                      _("Initial Setup creates your first user. Without it, you will not be able to log in and may need to reinstall the OS."),
				//                      "dialog-error",
				//                      Gtk.ButtonsType.CLOSE
				//                      );

				//              error_dialog.show_error_details(e.message);
				//              error_dialog.run();
				//              error_dialog.destroy();
				//      }

				//      return Source.REMOVE;
				//  });
			}
			return null;
		}

		public static unowned JS.Value start_authentication(JS.Context ctx,
		                                                    JS.Object function,
		                                                    JS.Object thisObject,
		                                                    JS.Value[] args,
		                                                    out unowned JS.Value exception) {
			debug("start_authentication function called");
			exception = null;

			string username = variant_from_value(ctx, args[0]).get_string();
			lightdm_greeter.authenticate(username);
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value cancel_authentication(JS.Context ctx,
		                                                     JS.Object function,
		                                                     JS.Object thisObject,
		                                                     JS.Value[] args,
		                                                     out unowned JS.Value exception) {
			debug("cancel_authentication function called");
			exception = null;

			lightdm_greeter.cancel_authentication();
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value login(JS.Context ctx,
		                                     JS.Object function,
		                                     JS.Object thisObject,
		                                     JS.Value[] args,
		                                     out unowned JS.Value exception) {
			debug("login function called");
			exception = null;
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value restart(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			debug("restart function called");
			exception = null;
			return JS.Value.boolean(ctx, LightDM.restart());
		}

		public static unowned JS.Value shutdown(JS.Context ctx,
		                                        JS.Object function,
		                                        JS.Object thisObject,
		                                        JS.Value[] args,
		                                        out unowned JS.Value exception) {
			debug("shutdown function called");
			exception = null;
			return JS.Value.boolean(ctx, LightDM.shutdown());
		}

		public static unowned JS.Value hibernate(JS.Context ctx,
		                                         JS.Object function,
		                                         JS.Object thisObject,
		                                         JS.Value[] args,
		                                         out unowned JS.Value exception) {
			debug("hibernate function called");
			exception = null;
			return JS.Value.boolean(ctx, LightDM.hibernate());
		}

		public static unowned JS.Value suspend(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			debug("suspend function called");
			exception = null;
			return JS.Value.boolean(ctx, LightDM.suspend());
		}

	}


	[CCode(cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
	public void webkit_web_extension_initialize(WebKit.WebExtension extension) {
		debug("core extension initilalization");
		jsapi = new JSApi();

		extension.page_created.connect(jsapi.on_page_created);
		var scriptWorld = WebKit.ScriptWorld.get_default();
		scriptWorld.window_object_cleared.connect(jsapi.on_window_object_cleared);
		//  Bus.own_name(BusType.SESSION, "io.github.webkit2gtk-greeter.JSApi", BusNameOwnerFlags.NONE,
		//               jsapi.on_bus_aquired, null, () => { warning("Could not aquire name"); });

		jsapi.ref();
	}
}
