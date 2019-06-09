
greeter_test_lib_sources = [
  'test-case.vala',
  'mock-object.vala'
]

greeter_test_lib_dependencies = [
  gee,
  glib,
  gio
]

greeter_test_lib = static_library('test-lib',
  greeter_test_lib_sources,
  dependencies: greeter_test_lib_dependencies,
  include_directories: config_h_dir,
  vala_args: greeter_vala_options,
  c_args: greeter_c_options,
)

greeter_test_sources = [
  'test-greeter.vala',
  'greeter/greeter-application-test.vala'
]
greeter_test_dependencies = [
  greeter_client_dep,
  gio,
  glib
]
greeter_test_dependencies += greeter_client_dependencies

greeter_test_bin = executable('greeter-test',
  sources : greeter_test_sources,
  dependencies: greeter_test_dependencies,
  link_with: greeter_test_lib,
  include_directories: config_h_dir,
  vala_args: greeter_vala_options
)
test('greeter-test', greeter_test_bin )


extension_test_sources = [
  'test-extension.vala',
  'extensions/utils-test.vala',
]
extension_test_dependencies = [
  gio,
  glib,
  json_glib,
  utils_dep,
  javascriptcoregtk,
  gee
]
# extension_test_dependencies += core_dependencies

extension_test_bin = executable('extension-test',
  sources : extension_test_sources,
  dependencies: extension_test_dependencies,
  link_with: greeter_test_lib,
  include_directories: config_h_dir,
  vala_args: greeter_vala_options
)

test('extension-test', extension_test_bin)
