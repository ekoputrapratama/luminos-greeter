using Luminos.JSUtils;
using Luminos.Utility;

namespace Luminos {

	public class LightDMApi : GLib.Object {
		private JS.Context* _context = null;
		private unowned LightDM.Greeter? greeter = null;
		private unowned LightDM.UserList? user_list = null;
		private ulong sm_id;
		private ulong sp_id;
		private ulong ac_id;
		public JS.Context* context {
			get {
				return _context;
			}
		}
		public LightDMApi(JS.Context context, LightDM.Greeter greeter, LightDM.UserList list) {
			this._context = context;
			this.greeter = greeter;
			this.user_list = list;

			sm_id = greeter.show_message.connect(show_message);
			sp_id = greeter.show_prompt.connect(show_prompt);

			//  greeter.notify["has-guest-account-hint"].connect(() => {
			//  	debug("has_guest_account_hint changed");
			//  	unowned JS.Object global = context.get_global_object();
			//  	unowned JS.Value lighdm_val = global.get_property(context, new JS.String("lightdm"));
			//  	if(is_defined(context, lighdm_val)) {
			//  	        unowned JS.Object obj = lighdm_val.to_object(context, null);
			//  	        obj.set_property(context,
			//  	                         new JS.String.with_utf8_c_string("has_guest_account"),
			//  	                         JS.Value.boolean(context, lightdm_greeter.has_guest_account_hint),
			//  	                         JS.PropertyAttribute.None);
			//  	}
			//  });
		}
		~LightDMApi() {
			greeter.show_prompt.disconnect(show_prompt);
			greeter.show_message.disconnect(show_message);
			context->collect_garbage();
			delete _context;
		}
		public void create_lightdm_object() {
			setup_lightdm_object(_context);
		}


		private void show_prompt(string text, LightDM.PromptType type = LightDM.PromptType.QUESTION) {
			debug("prompt: `%s' (%d)", text, type);

			unowned JS.Object global = context->get_global_object();
			unowned JS.Value lighdm_val = global.get_property(context, new JS.String("lightdm"));
			unowned JS.Object obj = lighdm_val.to_object(context, null);
			unowned JS.Value val = obj.get_property(context, new JS.String("onShowPrompt"));
			void*[] params = {to_js_string(context, text)};

			string type_str = "";
			if(type == LightDM.PromptType.SECRET) {
				type_str = "password";
				params += JS.Value.number(context, 1);
			} else if(type == LightDM.PromptType.QUESTION) {
				type_str = "question";
				params += JS.Value.number(context, 0);
			}

			if(!is_null_or_undefined(context, val)) {
				unowned JS.Object fun = val.to_object(context);
				if(fun.is_function(context)) {
					fun.call_as_function(context, fun, (JS.Value[]) params, null);
				}
			}

			// compatibility with antergos web-greeter
			JS.String script = new JS.String("if(typeof show_prompt === 'function') show_prompt('" + text + "','" + type_str + "');");
			context->evaluate_script(script);
		}

		private void show_message(string text, LightDM.MessageType type) {
			GLib.critical("message: `%s' (%d)", text, type);

			unowned JS.Object global = context->get_global_object();
			unowned JS.Value lighdm_val = global.get_property(context, new JS.String("lightdm"));
			unowned JS.Object obj = lighdm_val.to_object(context, null);
			unowned JS.Value val = obj.get_property(context, new JS.String("onShowMessage"));
			void*[] params = {to_js_string(context, text)};

			string type_str = "";

			if(type == LightDM.MessageType.INFO) {
				type_str = "info";
				params += JS.Value.number(context, 0);
			} else if(type == LightDM.MessageType.ERROR) {
				type_str = "error";
				params += JS.Value.number(context, 1);
			}

			if(!is_null_or_undefined(context, val)) {
				unowned JS.Object fun = val.to_object(context);
				if(fun.is_function(context)) {
					fun.call_as_function(context, fun, (JS.Value[]) params, null);
				}
			}

			// compatibility with antergos web-greeter
			JS.String script = new JS.String("if(typeof show_message === 'function') show_message('" + text + "','" + type_str + "');");
			context->evaluate_script(script);
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

		private unowned JS.Object setup_lightdm_object(JS.Context context) {
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

			unowned JS.Value uv = load_users(context, obj);
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
			                    JS.PropertyAttribute.None);
			return obj;
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

		private void setup_lightdm_variables(JS.Context ctx, JS.Object obj, out JS.Value exception = null) {
			unowned JS.Object promptType = ctx.make_object();
			promptType.set_property(ctx,
			                        new JS.String.with_utf8_c_string("QUESTION"),
			                        JS.Value.number(ctx, 0),
			                        JS.PropertyAttribute.ReadOnly);
			promptType.set_property(ctx,
			                        new JS.String.with_utf8_c_string("SECRET"),
			                        JS.Value.number(ctx, 1),
			                        JS.PropertyAttribute.ReadOnly);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("PromptType"),
			                 promptType,
			                 JS.PropertyAttribute.ReadOnly);

			unowned JS.Object messageType = ctx.make_object();
			messageType.set_property(ctx,
			                         new JS.String.with_utf8_c_string("INFO"),
			                         JS.Value.number(ctx, 0),
			                         JS.PropertyAttribute.ReadOnly);
			messageType.set_property(ctx,
			                         new JS.String.with_utf8_c_string("ERROR"),
			                         JS.Value.number(ctx, 1),
			                         JS.PropertyAttribute.ReadOnly);
			obj.set_property(ctx,
			                 new JS.String.with_utf8_c_string("MessageType"),
			                 messageType,
			                 JS.PropertyAttribute.ReadOnly);

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
			                 new JS.String.with_utf8_c_string("select_user_hint"),
			                 to_js_string(ctx, lightdm_greeter.select_user_hint),
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
			                 JS.Value.number(ctx, user_list.length),
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

		private void setup_lightdm_functions(JS.Context context, JS.Object obj, out JS.Value exception = null) {
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
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("authenticate"),
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

			fun = obj.get_property(context, new JS.String.with_utf8_c_string("respond"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding respond function");
				unowned JS.Object respond_fun = context.make_function(new JS.String.with_utf8_c_string("respond"), respond);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("respond"),
				                 respond_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			// Compatibility with Antergos old api
			fun = obj.get_property(context, new JS.String.with_utf8_c_string("provide_secret"), out exception);
			if(is_null_or_undefined(context, fun)) {
				debug("adding provide_secret function");
				unowned JS.Object provide_secret_fun = context.make_function(new JS.String.with_utf8_c_string("provide_secret"), respond);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("provide_secret"),
				                 provide_secret_fun,
				                 JS.PropertyAttribute.ReadOnly);
			}
		}
		public static unowned JS.Value respond(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			exception = null;
			try {
				var response = variant_from_value(ctx, args[0]).get_string();
				if(response != null) {
					GLib.message("respond to lightdm");
					lightdm_greeter.respond(response);
				}
			} catch(JSApiError e) {
				GLib.critical("Error when parsing credential : %s", e.message);
			} catch(Error e) {
				GLib.critical(e.message);
			}
			return JS.Value.undefined(ctx);
		}
// Compatibility with Antergos old api
		public static unowned JS.Value provide_secret(JS.Context ctx,
		                                              JS.Object function,
		                                              JS.Object thisObject,
		                                              JS.Value[] args,
		                                              out unowned JS.Value exception) {
			respond(ctx, function, thisObject, args, out exception);
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
				GLib.error(exception_to_string(ctx, exception));
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

		private unowned JS.Value? load_users(JS.Context ctx, JS.Object obj) {
			void*[] params = {};
			JS.Value? exception;

			if(user_list.length > 0) {
				unowned GLib.List<LightDM.User> users = user_list.users;
				users.foreach((user) => {
					debug("user : %s", user.name);
					params += (void*)user_to_js_object(ctx, user);
				});

				unowned JS.Object arr = ctx.make_array((JS.Value[]) params, out exception);
				return arr;
			} else {
				/* We're not certain that scaling factor will change, but try to wait for GSD in case it does */
				//  Timeout.add(500, () => {
				//  	if(user_list.length > 0) {
        //      unowned GLib.List<LightDM.User> users = user_list.users;
        //      users.foreach((user) => {
				//  			debug("user : %s\n", user.name);
				//  			params += (void*)user_to_js_object(ctx, user);
        //      });
        //      unowned JS.Object arr = ctx.make_array((JS.Value[]) params, out exception);

				//  	}
				//  	return Source.REMOVE;
				//  });
			}
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value start_authentication(JS.Context ctx,
		                                                    JS.Object function,
		                                                    JS.Object thisObject,
		                                                    JS.Value[] args,
		                                                    out unowned JS.Value exception) {
			debug("start_authentication function called");
			exception = null;
			try {
				string username = variant_from_value(ctx, args[0]).get_string();
				lightdm_greeter.authenticate(username);
			} catch(JSApiError e) {
				GLib.critical("Error when parsing username : %s", e.message);
			} catch(Error e) {
				GLib.critical("Error when trying to authenticate user : %s", e.message);
			}
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value cancel_authentication(JS.Context ctx,
		                                                     JS.Object function,
		                                                     JS.Object thisObject,
		                                                     JS.Value[] args,
		                                                     out unowned JS.Value exception) {
			debug("cancel_authentication function called");
			exception = null;
			try {
				lightdm_greeter.cancel_authentication();
			} catch(Error e) {
				GLib.critical("Error when trying to cancel authentication : %s", e.message);
			}
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value login(JS.Context ctx,
		                                     JS.Object function,
		                                     JS.Object thisObject,
		                                     JS.Value[] args,
		                                     out unowned JS.Value exception) {
			debug("login function called");
			exception = null;
			try {
				//  string username = variant_from_value(ctx, args[0]).get_string();
				string session = variant_from_value(ctx, args[1]).get_string();
				lightdm_greeter.start_session(session);
			} catch(GLib.Error e) {
				GLib.critical("Error when trying to start session for authenticated user : %s", e.message);
			}

			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value restart(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			debug("restart function called");
			exception = null;
			try {
				return JS.Value.boolean(ctx, LightDM.restart());
			} catch(Error e) {
				GLib.critical("Failed to restart : %s", e.message);
			}
			return JS.Value.boolean(ctx, false);
		}

		public static unowned JS.Value shutdown(JS.Context ctx,
		                                        JS.Object function,
		                                        JS.Object thisObject,
		                                        JS.Value[] args,
		                                        out unowned JS.Value exception) {
			debug("shutdown function called");
			exception = null;
			try {
				return JS.Value.boolean(ctx, LightDM.shutdown());
			} catch(Error e) {
				GLib.critical("Failed to shutdown : %s", e.message);
			}
			return JS.Value.boolean(ctx, false);
		}

		public static unowned JS.Value hibernate(JS.Context ctx,
		                                         JS.Object function,
		                                         JS.Object thisObject,
		                                         JS.Value[] args,
		                                         out unowned JS.Value exception) {
			debug("hibernate function called");
			exception = null;
			try {
				return JS.Value.boolean(ctx, LightDM.hibernate());
			} catch(Error e) {
				GLib.critical("Failed to hibernate : %s", e.message);
			}
			return JS.Value.boolean(ctx, false);
		}

		public static unowned JS.Value suspend(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			GLib.debug("suspend function called");
			exception = null;
			try {
				return JS.Value.boolean(ctx, LightDM.suspend());
			} catch(Error e) {
				GLib.critical("Failed to suspend : %s", e.message);
			}
			return JS.Value.boolean(ctx, false);
		}
	}
}
