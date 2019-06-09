using GLib;
using WebKit;

namespace LuminosGreeter {

	public class WebContainer: WebView {
		private static List<UserScript>? scripts = null;

		public WebContainer() {
			load_resources();
			UserContentManager content_manager = new UserContentManager();
			foreach(UserScript script in scripts) {
				content_manager.add_script(script);
			}
			Object(user_content_manager: content_manager);
			this.init();
		}

		public void init() {

			WebKit.Settings settings = this.get_settings();
			settings.enable_javascript = true;
			settings.allow_file_access_from_file_urls = true;
			settings.allow_universal_access_from_file_urls = true;
			settings.enable_java = false;
			settings.enable_media_stream = true;
			settings.javascript_can_access_clipboard = true;

			WebKit.WebContext context = get_context();
			context.set_process_model(WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES);
			context.set_tls_errors_policy(WebKit.TLSErrorsPolicy.IGNORE);
		}

		/** Loads an application-specific WebKit JavaScript script. */
		public static UserScript load_app_script(string name)
		throws Error {
			return new UserScript(
				GioUtil.read_resource(name),
				UserContentInjectedFrames.TOP_FRAME,
				UserScriptInjectionTime.START,
				null,
				null
				);
		}

		public static void load_resources() {
			scripts = new List<UserScript>();
			try {
				scripts.append(load_app_script("greeter_util.js"));
				scripts.append(load_app_script("greeter_config.js"));
				scripts.append(load_app_script("moment-with-locales.min.js"));
				scripts.append(load_app_script("theme_utils.js"));
			} catch(Error e) {
				critical("failed when loading user scripts : %s", e.message);
			}
		}
	}
}
