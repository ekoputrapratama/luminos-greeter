using WebKit;
using Gtk;
using Gdk;
using GLib.Environment;
using Cairo;


namespace LuminosGreeter {
	[GtkTemplate(ui = "/io/github/luminos-greeter/window.ui")]
	public class Window : Gtk.ApplicationWindow {
		public new GreeterApplication application {
			get { return (GreeterApplication) base.get_application(); }
			set { base.set_application(value); }
		}
		LuminosGreeter.WebContainer webview;
		bool enable_transparancy = false;

		construct
		{
			type_hint = Gdk.WindowTypeHint.DESKTOP;
		}

		public Window(GreeterApplication app) {
			Object(application: app);
			string ext_path = app.get_extensions_dir().get_path();
			debug("extensions directory: %s\n", ext_path);

			WebKit.WebContext.get_default().set_web_extensions_directory(ext_path);

			set_default_size(Gdk.Screen.width(), Gdk.Screen.height());

			this.screen_changed.connect(on_window_screen_changed);


			this.webview = new LuminosGreeter.WebContainer();
			WebKit.Settings settings = this.webview.get_settings();
			settings.enable_plugins = false;
			settings.enable_developer_extras = app.is_installed;
			settings.enable_webgl = true;

			this.webview.load_changed.connect(load_changed);
			add(this.webview);

			var screen = this.get_screen();
			this.focus_out_event.connect(on_window_focus_out);

			show_all();
		}

		public void set_type_hint(Gdk.WindowTypeHint type) {
			type_hint = type;
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

		private bool on_window_focus_out(Gdk.EventFocus e) {
			debug("window focus out");
			return true;
		}

		public void on_window_screen_changed(Gdk.Screen ? previous_screen) {
			debug("window screen changed");
			var screen = this.get_screen();
			var visual = screen.get_rgba_visual();

			if(visual == null) {
				warning("Screen does not support alpha channels!");
				visual = screen.get_system_visual();
			}

			this.set_visual(visual);
		}

		[GtkCallback]
		public bool on_window_draw(Widget widget, Context ctx) {
			return false;
		}

		public void load_changed(LoadEvent event) {

			switch(event) {
			case LoadEvent.COMMITTED:
				//  message("on load_changed");

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
