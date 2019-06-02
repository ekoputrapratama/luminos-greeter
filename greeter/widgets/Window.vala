using WebKit;
using Gtk;
using Gdk;
using GLib.Environment;
using Cairo;
namespace WebkitGtkGreeter {
	[GtkTemplate(ui = "/io/github/webkitgtk-greeter/ui/window.ui")]
	public class Window : Gtk.Window {

		WebkitGtkGreeter.WebContainer webview;
		bool enable_transparancy = false;
		private int count = 0;

		construct
		{
			type_hint = Gdk.WindowTypeHint.DESKTOP;
		}

		public Window(unowned AppOptions opts) {
			string ext_path = "/opt/webkitgtk-greeter/extensions";

			if(opts.dev) {
				var destination = File.new_for_path("build/extensions");
				ext_path = destination.get_path();
				message("extensions directory: %s\n", ext_path);
			}
			WebKit.WebContext.get_default().set_web_extensions_directory(ext_path);

			set_default_size(screen.width(), screen.height());

			this.screen_changed.connect(on_window_screen_changed);

			string cacheDir = GLib.Path.build_filename(get_user_cache_dir(), "webkitgtk-greeter", null);
			WebKit.WebContext context;

			unowned WebKit.WebsiteDataManager* dataManager = new WebKit.WebsiteDataManager.ephemeral();

			context = new WebKit.WebContext.with_website_data_manager(dataManager);
			context.set_process_model(WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES);
			context.set_tls_errors_policy(WebKit.TLSErrorsPolicy.IGNORE);

			this.webview = new WebkitGtkGreeter.WebContainer.with_context(context);

			UserContentManager contman = this.webview.user_content_manager;
			this.webview.load_changed.connect(load_changed);
			add(this.webview);

			this.webview.on_string_callback.connect(() => {
				message("on_string_callback called");
			});

			var screen = this.get_screen();
			var monitors = this.get_monitor_plug_names(this.get_screen());
			this.focus_out_event.connect(on_window_focus_out);

			show_all();
		}

		public void set_type(Gdk.WindowTypeHint type) {
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

		public string[] get_monitor_plug_names(Gdk.Screen screen)
		{
			Gdk.Display display = screen.get_display();
			int n_monitors = display.get_n_monitors();
			var result = new string[n_monitors];

			for(int i = 0; i < n_monitors; i++) {
				var monitor = display.get_monitor(i);
				message("monitor model %s", monitor.get_model());
				message("monitor width %d", monitor.get_geometry().width);
				result[i] = monitor.get_model() ?? "PLUG_MONITOR_%i".printf(i);
			}
			return result;
		}
		private bool on_window_focus_out(Gdk.EventFocus e) {
			message("window focus out");
			return true;
		}
		private bool on_window_configure_event(Gtk.Widget sender, Gdk.EventConfigure event) {
			message("window configure event");
			return true;
		}

		public void on_window_screen_changed(Gdk.Screen ? previous_screen) {
			message("window screen changed");
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
		public static Region create_region(Widget widget, int m, int posX, int posY) {
			var rectangle = Cairo.RectangleInt() {
				x = posX,
				y = posY,
				width = widget.get_allocated_width(),
				height = widget.get_allocated_height() - m
			};

			var region = new Region.rectangle(rectangle);

			return region;
		}

		private void update_input_shape() {
			// Set an input shape so that the view outside the dock is not clickable
			var dock_region = create_region(this, 0, 0, 0);
			var top_region = create_region(this, 64, 0, 0);
			dock_region.subtract(top_region);

			this.input_shape_combine_region(dock_region);
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
