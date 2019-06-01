
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
  'test-client.vala',
  'greeter/greeter-application-test.vala'
]
greeter_test_dependencies = [
  greeter_client_dep,
  gio,
  glib
]
greeter_test_dependencies += greeter_client_dependencies

greeter_test_bin = executable('greeter-application-test', 
  sources : greeter_test_sources,
  dependencies: greeter_test_dependencies,
  link_with: greeter_test_lib,
  include_directories: config_h_dir,
  vala_args: greeter_vala_options
)
test('greeter-application', greeter_test_bin, args : ['--somearg'], env : ['ENVVAR=val'])
