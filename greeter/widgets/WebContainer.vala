using GLib;
using WebKit;
using JS;
using Gee;
using Luminos.GioUtil;

namespace Luminos {

	public class WebContainer: WebView {

		public WebContainer() {
			UserContentManager content_manager = load_resources();
			GLib.Object(user_content_manager: content_manager);
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
			settings.enable_accelerated_2d_canvas = true;

			WebKit.WebContext context = get_context();
			context.set_process_model(WebKit.ProcessModel.MULTIPLE_SECONDARY_PROCESSES);
			context.set_tls_errors_policy(WebKit.TLSErrorsPolicy.IGNORE);

			// register custom uri scheme to be used in theme and html background
			context.register_uri_scheme("backgrounds", handle_background_uri_request);
			context.register_uri_scheme("themes", handle_theme_uri_request);
			context.register_uri_scheme("vendor", handle_vendor_uri_request);
		}
		public void handle_vendor_uri_request(URISchemeRequest request) {
			message("handle_vendor_uri_request");
			GreeterApplication app = GreeterApplication.instance;

			var end_path = request.get_uri().replace("vendor://", "");
			var path = app.get_vendor_dir().get_path() + Path.DIR_SEPARATOR_S + end_path;

			File? file = get_real_file(path);
			string mime = get_mime_type(file.get_basename());

			if(file != null && file.query_exists()) {
				try {
					uint8[] contents;
					string tag_out;
					file.load_contents(null, out contents, out tag_out);

					var stream = new MemoryInputStream.from_data(contents, GLib.free);
					request.finish(stream, contents.length, mime);
				} catch(Error e) {
					request.finish_error(new GLib.FileError.NOENT("cannot finish request."));
					critical("cannot handle request from vendor uri :%s", e.message);
				}
			} else {
				request.finish_error(new GLib.FileError.NOENT("cannot finish request caused by file doesn't exists."));
			}
		}
		private string remove_query_params(string path) {
			try {
				var regex = new Regex("(.*)\\?(.*)");
				var split = regex.split(path);
				if(split.length > 2) {
					return split[1];
				}
			} catch(RegexError e) {
				critical("invalid regex used : %s", e.message);
			}
			return path;
		}
		public void handle_theme_uri_request(URISchemeRequest request) {
			message("handle_theme_uri_request");
			GreeterApplication app = GreeterApplication.instance;

			var end_path = request.get_path();
			message("end_path %s", end_path);
			var theme_name = remove_query_params(request.get_uri()).replace("themes://", "").replace(end_path, "");
			var path = app.get_themes_dir().get_path() + Path.DIR_SEPARATOR_S + theme_name + end_path;

			File file = get_real_file(path);
			string mime = get_mime_type(file.get_basename());

			if(file.query_exists()) {
				try {
					uint8[] contents;
					string tag_out;
					file.load_contents(null, out contents, out tag_out);

					var stream = new MemoryInputStream.from_data(contents, GLib.free);
					request.finish(stream, contents.length, mime);
				} catch(Error e) {
					request.finish_error(new GLib.FileError.NOENT("cannot finish request."));
					critical("cannot handle request from vendor uri :%s", e.message);
				}
			} else {
				request.finish_error(new GLib.FileError.NOENT("cannot finish request."));
			}
		}
		public void handle_background_uri_request(URISchemeRequest request) {
			message("handle_background_uri_request");
			GreeterApplication app = GreeterApplication.instance;

			var end_path = request.get_path();
			var bg_name = request.get_uri().replace("backgrounds://", "").replace(end_path, "");
			var path = app.get_backgrounds_dir().get_path() + Path.DIR_SEPARATOR_S + bg_name + end_path;

			File file = get_real_file(path);
			string mime = get_mime_type(file.get_basename());

			if(file.query_exists()) {
				try {
					// this equals to Buffer/Uint8Array in javascript
					uint8[] contents;
					string tag_out;
					file.load_contents(null, out contents, out tag_out);

					var stream = new MemoryInputStream.from_data(contents, GLib.free);
					request.finish(stream, contents.length, mime);
				} catch(Error e) {
					request.finish_error(new GLib.FileError.NOENT("cannot finish request."));
					critical("cannot handle request from vendor uri :%s", e.message);
				}
			} else {
				request.finish_error(new GLib.FileError.NOENT("cannot finish request."));
			}
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

		public static UserContentManager load_resources() {
			UserContentManager content_manager = new UserContentManager();
			try {
				content_manager.add_script(load_app_script("greeter_util.js"));
				content_manager.add_script(load_app_script("greeter_config.js"));
				content_manager.add_script(load_app_script("moment-with-locales.min.js"));
				content_manager.add_script(load_app_script("theme_utils.js"));
			} catch(Error e) {
				critical("failed when loading user scripts : %s", e.message);
			}
			return content_manager;
		}
	}
}
