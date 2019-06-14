using Luminos.Utility;


class UtilsTest : TestCase {
	string? bg_def = null;
	string? valid_conf = null;
	string? invalid_conf = null;
	public UtilsTest() {
		base("UtilsTest");
		add_test("valid_bgconf", valid_bgconf);
		add_test("is_html_bg", html_backgrounds);
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

	public void html_backgrounds() throws Error {
		assert_true(is_html_bg(bg_def));
	}

	public void valid_bgconf() throws GLib.Error {
		assert_true(is_valid_bgconf(valid_conf));
		assert_false(is_valid_bgconf(invalid_conf));
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
		File.new_for_path("bg_test").make_directory();
		bg_def = create_file("bg_test/index.bg", {
			"[background]\n",
			"Name=TestBG\n",
			"url=index.html",
			"webgl=false"
		});

		var bg_index = create_file("bg_test/index.html", {
			"<html>",
			"<head><title>Background Test</title></head>",
			"<body><h1>Hello World!</h1></body>",
			"</html>"
		});

		valid_conf = create_file("bg_test/conf-valid.bg", {
			"[background]\n",
			"Name=TestBG\n"
		});

		invalid_conf = create_file("bg_test/conf-invalid.bg", {
			"[theme]\n",
			"Name=TestBG\n"
		});;
	}

	public override void tear_down() {
		delete_file(File.new_for_path(valid_conf));
		delete_file(File.new_for_path(invalid_conf));
	}
}
