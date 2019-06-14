using WebKit;
using JS;
using GLib;
using Gtk;
using Luminos.JSUtils;
using Luminos.Utility;

[CCode(cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
public void webkit_web_extension_initialize(WebKit.WebExtension extension) {
	message("config-manager extension initialization");
	Luminos.ClientConfigManager instance = new Luminos.ClientConfigManager();

	extension.page_created.connect(instance.on_page_created);
	var scriptWorld = WebKit.ScriptWorld.get_default();
	scriptWorld.window_object_cleared.connect(instance.on_window_object_cleared);

	// Ref it so it doesn't get free'ed right away
	instance.ref();
}

namespace Luminos {

	class ClientConfigManager : GLib.Object {
		private WebKit.WebPage page;
		private ConfigManager config_mgr;
		public ClientConfigManager() {

		}

		public void on_page_created(WebKit.WebExtension extension, WebKit.WebPage page) {
			this.page = page;
		}

		public void on_window_object_cleared(ScriptWorld world, WebPage page, WebKit.Frame frame) {
			debug("config-manager window object cleared");
			unowned JS.Context context = (JS.GlobalContext)frame.get_javascript_context_for_script_world(world);
			config_mgr = new ConfigManager.with_js_context(context);
			unowned JS.Object class_obj = config_mgr.make_class();
			unowned JS.Object global = context.get_global_object();

			global.set_property(context,
			                    new JS.String.with_utf8_c_string("ConfigManager"),
			                    class_obj,
			                    JS.PropertyAttribute.ReadOnly);
			debug("adding ConfigManager class finished");
		}
	}

}
