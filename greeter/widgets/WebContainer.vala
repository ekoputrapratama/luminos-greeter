using Gee;
using GLib;
using WebKit;

namespace WebkitGtkGreeter {

	[DBus(name = "io.github.webkitgtk-greeter.JSApi")]
	interface JSApi : Object {
		public signal void on_string_callback();
	}

	public class WebContainer: WebView {
		private JSApi messenger = null;
		public File launchers_folder { get; private set; }
		public File config_folder { get; construct; }
		public WebContext context {get; set;}
		public signal void on_string_callback();

		public WebContainer.with_context(WebContext ctx) {
			GLib.Object(context: ctx);
			this.init();
		}
		public WebContainer() {
			this.init();
		}
		construct {

		}
		public void init() {

			WebKit.Settings settings = this.get_settings();
			settings.enable_plugins = true;
			settings.enable_javascript = true;
			settings.allow_file_access_from_file_urls = true;
			settings.allow_universal_access_from_file_urls = true;
			settings.enable_developer_extras = true;
			settings.enable_webgl = true;
			//  Bus.watch_name(BusType.SESSION, "io.github.webkit2gtk-greeter.JSApi", BusNameWatcherFlags.NONE,
			//                 (connection, name, owner) => { on_extension_appeared(connection, name, owner); }, null);
		}
		private void on_extension_appeared(DBusConnection connection, string name, string owner) {
			try {
				messenger = connection.get_proxy_sync("io.github.webkit2gtk-greeter.JSApi", "/io/github/webkit2gtk-greeter/jsapi",
				                                      DBusProxyFlags.NONE, null);
				messenger.on_string_callback.connect(() => {
					message("on_string_callback");
					on_string_callback();
				});
			} catch(IOError error) {
				warning("Problem connecting to extension: %s", error.message);
			}
		}

	}
}
