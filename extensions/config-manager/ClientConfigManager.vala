using WebKit;
using JS;
using GLib;
using Gtk;
using Webkit2gtkGreeter.JSUtils;
namespace Webkit2gtkGreeter {
	ClientConfigManager client = null;
	//  [DBus(name = "io.github.webkit2gtk-greeter.config-manager")]
	class ClientConfigManager : GLib.Object {
		private WebKit.WebPage page;
		private ConfigManager config_mgr;
		public ClientConfigManager() {
			config_mgr = new ConfigManager();
		}

		//  [DBus(visible = false)]
		//  public void on_bus_aquired(DBusConnection connection) {
		//      try {
		//              connection.register_object("/io/github/webkit2gtk-greeter/config-manager", this);
		//      } catch(IOError error) {
		//              warning("Could not register service config-manager: %s", error.message);
		//      }
		//  }
		//  [DBus(visible = false)]
		public void on_page_created(WebKit.WebExtension extension, WebKit.WebPage page) {
			this.page = page;
		}

		//  [DBus(visible = false)]
		public void on_window_object_cleared(ScriptWorld world, WebPage page, WebKit.Frame frame) {
			message("window object cleared");
			unowned JS.Context context = (JS.GlobalContext)frame.get_javascript_context_for_script_world(world);
			unowned JS.Object class_obj = config_mgr.make_class(context);
			unowned JS.Object global = context.get_global_object();
			global.set_property(context,
			                    new JS.String.with_utf8_c_string("ConfigManager"),
			                    class_obj,
			                    JS.PropertyAttribute.ReadOnly);
		}
		//  public ConfigManager get_instance() {
		//      return new ConfigManager();
		//  }
	}
	[CCode(cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
	void webkit_web_extension_initialize(WebKit.WebExtension extension) {
		message("config-manager extension initilalization");
		Webkit2gtkGreeter.client = new ClientConfigManager();
		extension.page_created.connect(client.on_page_created);
		var scriptWorld = WebKit.ScriptWorld.get_default();
		scriptWorld.window_object_cleared.connect(client.on_window_object_cleared);
		//  Bus.own_name(BusType.SESSION, "io.github.webkit2gtk-greeter.ClientConfigManager", BusNameOwnerFlags.NONE,
		//               client.on_bus_aquired, null, () => { warning("Could not aquire name"); });
	}
}
