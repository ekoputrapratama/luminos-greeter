using LuminosGreeter.Utility;
string? valid_conf = null;
string? invalid_conf = null;
class UtilsTest : TestCase {

	public UtilsTest() {
		base("UtilsTest");
		add_test("valid_bgconf", valid_bgconf);
		add_test("path_exists", path_exists);
		add_test("get_file_extension", file_extension);
		add_test("directory_validation", directory_validation);
		add_test("load_config_file", load_conf_file);
	}

	public void load_conf_file() throws GLib.Error {
		var conffile = create_file("test_load.conf", {
			"[greeter]",
			"debug_mode          = false",
			"detect_theme_errors = true",
			"screensaver_timeout = 300",
			"secure_mode         = true",
			"time_format         = LT",
			"time_language       = auto",
			"webkit_theme        = luminos",
			"",
			"[branding]",
			"background_images = /usr/share/backgrounds",
			"logo              = /usr/share/pixmaps/manjaro.png",
			"user_image        = /usr/share/pixmaps/manjaro-logo-user.png"
		});
		var conf = load_config_file(conffile);
		assert_true(conf.size == 2);
		var branding = conf.get("branding");
		var greeter = conf.get("greeter");

		assert_true(greeter.size > 0);
		assert_true(greeter.size == 7);
		assert_true(branding.size > 0);
		assert_true(branding.size == 3);

		File.new_for_path(conffile).delete();
	}


	public void path_exists() throws GLib.Error {
		var path = create_file("path_exists_test.txt", {
			"This is a test file"
		});
		assert_true(file_path_exists(path));
	}
	public void directory_validation() throws GLib.Error {
		var dir = File.new_for_path("test_dir");
		var file = File.new_for_path(valid_conf);
		dir.make_directory();

		assert_true(is_directory(dir));
		assert_false(is_directory(file));

		FileInfo file_info = file.query_info(FileAttribute.STANDARD_TYPE, 0);
		FileInfo dir_info = dir.query_info(FileAttribute.STANDARD_TYPE, 0);
		assert_true(is_directory_info(dir_info));
		assert_false(is_directory_info(file_info));

		dir.delete();
	}
	public void file_extension() throws GLib.Error {
		var name = "test.txt";
		var ext = get_file_extension(name);
		assert_true(ext == "txt");
	}

	public override void set_up() {

	}

	public override void tear_down() {

	}
}
