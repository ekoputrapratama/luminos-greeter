using WebKit;
using JS;
using GLib;
using Gtk;
using Webkit2gtkGreeter.JSUtils;
using LightDM;

namespace Webkit2gtkGreeter {
	JSApi jsapi = null;
	private LightDM.Greeter lightdm_greeter;
	private unowned LightDM.UserList lightdm_user_list;

	[DBus(name = "io.github.webkit2gtk-greeter.JSApi")]
	public class JSApi : GLib.Object {
		private int count = 0;
		private WebKit.WebPage page;
		private unowned JS.Object lightdm_obj = null;
		public signal void on_string_callback();

		construct {
			lightdm_greeter = new LightDM.Greeter();
			lightdm_greeter.show_message.connect(show_message);
			lightdm_greeter.show_prompt.connect(show_prompt);
			//  lightdm_greeter.authentication_complete.connect (authentication_complete);

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
		}
		[DBus(visible = false)]
		private void authentication_complete() {
			if(lightdm_greeter.is_authenticated) {
				//  var action_group = get_action_group("session");
				try {
					//  lightdm_greeter.start_session_sync(action_group.get_action_state("select").get_string());
				} catch(Error e) {
					error(e.message);
				}
			} else {
				//  if(current_card is Greeter.UserCard) {
				//      switch_to_card((Greeter.UserCard)current_card);
				//  }

				//  current_card.connecting = false;
				//  current_card.wrong_credentials();
			}
		}
		[DBus(visible = false)]
		private void show_message(string text, LightDM.MessageType type) {

			//  critical ("message: `%s' (%d): %s", text, type);
			/*var messagetext = string_to_messagetext(text);
			   if (messagetext == MessageText.FPRINT_SWIPE || messagetext == MessageText.FPRINT_PLACE) {
			    // For the fprint module, there is no prompt message from PAM.
			    send_prompt (PromptType.FPRINT);
			   }
			   current_login.show_message (type, messagetext, text);*/
		}
		[DBus(visible = false)]
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
		[DBus(visible = false)]
		private async void load_users() {
			try {
				yield lightdm_greeter.connect_to_daemon(null);
			} catch(Error e) {
				critical(e.message);
			}

			lightdm_greeter.notify_property("show-manual-login-hint");
			lightdm_greeter.notify_property("has-guest-account-hint");

			if(lightdm_user_list.length > 0) {
				lightdm_user_list.users.foreach((user) => {
					//  add_card(user);
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

				if(lightdm_greeter.default_session_hint != null) {
					//  get_action_group("session").activate_action("select", new GLib.Variant.string (lightdm_greeter.default_session_hint));
				}
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
		}
		[DBus(visible = false)]
		public void on_bus_aquired(DBusConnection connection) {
			try {
				message("registering dbus object");
				connection.register_object("/io/github/webkit2gtk-greeter/jsapi", this);
			} catch(IOError error) {
				warning("Could not register service jsapi: %s", error.message);
			}
		}

		[DBus(visible = false)]
		public void on_page_created(WebKit.WebExtension extension, WebKit.WebPage page) {
			message("page-created");
			this.page = page;
		}

		[DBus(visible = false)]
		public void on_window_object_cleared(ScriptWorld world, WebPage page, WebKit.Frame frame) {
			message("window object cleared");
			unowned JS.Context context = (JS.GlobalContext)frame.get_javascript_context_for_script_world(world);


			//  unowned JS.Object global = context.get_global_object();

			//  unowned JS.Object cb = context.make_function(new JS.String.with_utf8_c_string("sayHello"), string_callback);
			//  unowned JS.Value obj = JSUtils.object_from_JSON(context, "{
			//    \"number\": 1,
			//    \"string\": \"Hello World!\",
			//    \"array\": [\"str1\",\"str2\",\"str3\"]
			//  }");
			build_global_object(context);
		}
		[DBus(visible = false)]
		private void build_global_object(JS.Context context) {
			unowned JS.Object global = context.get_global_object();
			JS.Value exception;
			unowned JS.Object obj = context.make_object();

			message("checking restart function");
			unowned JS.Value res = obj.get_property(context, new JS.String.with_utf8_c_string("restart"), out exception);
			if(res.is_null(context) || res.is_undefined(context)) {
				message("adding restart function");
				unowned JS.Object restartFun = context.make_function(new JS.String.with_utf8_c_string("restart"), restart);
				obj.set_property(context,
				                 new JS.String.with_utf8_c_string("restart"),
				                 restartFun,
				                 JS.PropertyAttribute.ReadOnly);
			}

			global.set_property(context,
			                    new JS.String.with_utf8_c_string("lightdm"),
			                    obj,
			                    JS.PropertyAttribute.ReadOnly);
		}
		[DBus(visible = false)]
		private void build_functions() {

		}
		[DBus(visible = false)]
		public static async void build_sessions() {
			var dir = File.new_for_path("/usr/share/xsessions/");
			try {
				// asynchronous call, to get directory entries
				var e = yield dir.enumerate_children_async(FileAttribute.STANDARD_NAME,
				                                           0, Priority.DEFAULT);
				while(true) {
					// asynchronous call, to get entries so far
					var files = yield e.next_files_async(10, Priority.DEFAULT);
					if(files == null) {
						break;
					}
					// append the files found so far to the list
					foreach(var info in files) {
						var file = File.new_for_path("/usr/share/xsessions/");
						message(info.get_name());
					}
				}
			} catch(Error err) {
				stderr.printf("Error: list_files failed: %s\n", err.message);
			}
		}
		[DBus(visible = false)]
		private void build_users() {

		}
		public static unowned JS.Value restart(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			message("restart function called");
			exception = null;
			return JS.Value.undefined(ctx);
		}
		public static unowned JS.Value shutdown(JS.Context ctx,
		                                        JS.Object function,
		                                        JS.Object thisObject,
		                                        JS.Value[] args,
		                                        out unowned JS.Value exception) {
			message("shutdown function called");
			exception = null;
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value hibernate(JS.Context ctx,
		                                         JS.Object function,
		                                         JS.Object thisObject,
		                                         JS.Value[] args,
		                                         out unowned JS.Value exception) {
			message("hibernate function called");
			exception = null;
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value suspend(JS.Context ctx,
		                                       JS.Object function,
		                                       JS.Object thisObject,
		                                       JS.Value[] args,
		                                       out unowned JS.Value exception) {
			message("suspend function called");
			exception = null;
			return JS.Value.undefined(ctx);
		}

		public static unowned JS.Value string_callback(JS.Context ctx,
		                                               JS.Object function,
		                                               JS.Object thisObject,
		                                               JS.Value[] args,
		                                               out unowned JS.Value exception) {
			exception = null;
			unowned JS.Value undefined = JS.Value.undefined(ctx);

			Variant[] ? data = null;

			try {

				for(var i = 0; i < args.length; i++) {
					data[i] = variant_from_value(ctx, args[i]);
				}
				if(jsapi != null) {
					jsapi.on_string_callback();
					message("string_callback got called");
				}
				unowned JS.Value str = JS.Value.string(ctx, new JS.String("Hello From Native Code"));
				return str;
			} catch(JSApiError e) {
				message(e.message);
				exception = create_exception(ctx, "Argument %d: %s".printf(1, e.message));
				return undefined;
			}
			return undefined;
		}
	}


	[CCode(cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
	void webkit_web_extension_initialize(WebKit.WebExtension extension) {
		message("core extension initilalization");
		Webkit2gtkGreeter.jsapi = new JSApi();
		//  jsapi.build_sessions();
		extension.page_created.connect(jsapi.on_page_created);
		var scriptWorld = WebKit.ScriptWorld.get_default();
		scriptWorld.window_object_cleared.connect(jsapi.on_window_object_cleared);
		Bus.own_name(BusType.SESSION, "io.github.webkit2gtk-greeter.JSApi", BusNameOwnerFlags.NONE,
		             jsapi.on_bus_aquired, null, () => { warning("Could not aquire name"); });
	}
}
