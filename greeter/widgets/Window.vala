using WebKit;
using Gtk;
using Gdk;
using GLib.Environment;
using Cairo;


namespace Luminos {
	public class GreeterWindow : Gtk.Window {
		Luminos.WebContainer webview;
		bool enable_transparancy = false;

		construct {
			accept_focus = true;
			type_hint = Gdk.WindowTypeHint.DESKTOP;
			skip_taskbar_hint = true;
			skip_pager_hint = true;
			decorated = false;
		}

		public GreeterWindow() {
			GreeterApplication app = GreeterApplication.instance;
			string ext_path = app.get_extensions_dir().get_path();
			debug("extensions directory: %s\n", ext_path);

			WebKit.WebContext.get_default().set_web_extensions_directory(ext_path);

			set_default_size(Gdk.Screen.width(), Gdk.Screen.height());

			this.screen_changed.connect(on_window_screen_changed);


			this.webview = new Luminos.WebContainer();
			WebKit.Settings settings = this.webview.get_settings();
			settings.enable_plugins = false;
			settings.enable_developer_extras = app.is_debug_mode;
			settings.enable_webgl = true;

			/* we cannot use on_window_object_cleared in main process so we listen for load changed signal.  */
			this.webview.load_changed.connect(load_changed);
			add(this.webview);

			show_all();
		}

		public void set_enable_transparancy() {
			// enable transparancy
			var screen = this.get_screen();
			var visual = screen.get_rgba_visual();

			if(visual == null) {
				warning("Screen does not support alpha channels!");
				visual = screen.get_system_visual();
				enable_transparancy = false;
			} else {
				enable_transparancy = true;
			}

			this.set_visual(visual);
		}

		public bool transparancy_enabled() {
			return enable_transparancy;
		}

		public void set_background_color(Gdk.RGBA color) {
			this.webview.set_background_color(color);
		}

		public void on_window_screen_changed(Gdk.Screen ? previous_screen) {
			debug("window screen changed");
			this.set_enable_transparancy();
		}

		public void load_changed(LoadEvent event) {

			switch(event) {
			  case LoadEvent.COMMITTED:
				  message("on LOAD_COMMITED");
				  GreeterApplication app = GreeterApplication.instance;
				  this.webview.run_javascript("window.THEMES_DIR = '" + app.get_themes_dir().get_path() + "';");
				  this.webview.run_javascript("window.CURRENT_THEME = '" + app.current_theme + "';");
				  this.webview.run_javascript("window.BACKGROUNDS_DIR = '" + app.get_backgrounds_dir().get_path() + "';");
				  break;
			}
		}

		public void load(string url, bool showInspector) {
			if(showInspector) {
				var inspector = this.webview.get_inspector();
				inspector.show();
			}
			this.webview.load_uri(url);
		}
	}
}
