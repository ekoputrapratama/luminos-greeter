

greeter_c_options = [
  '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
  '-lm',
  # '-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"',
  '-DLOCALEDIR=\""$(localedir)"\"',
	# '-DVERSION=\"$(VERSION)\"',
	'-DPKGDATADIR=\""$(pkgdatadir)"\"',
  '-include', 'config.h'
]

greeter_vala_options = [
  '--target-glib=@0@'.format(target_glib),
  '--enable-checking'
]

# Symbols for valac's preprocessor must be defined as compiler args,
# not in the code or in config.h
if reference_tracking
  geary_vala_options += [ '--define=REF_TRACKING' ]
endif
if not poodle
  geary_vala_options += [ '--define=DISABLE_POODLE' ]
endif

config_header = configure_file (
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

greeter_resources = gnome.compile_resources('webkit2gtk-greeter-resources',
  'webkit2gtk-greeter.gresource.xml'
)

greeter_client_vala_sources = files(
  'widgets/Window.vala',
  'widgets/WebContainer.vala',
  'GreeterApplication.vala',
  'utils/ConfigReader.vala',
)

greeter_client_sources = [
  greeter_client_vala_sources,
  greeter_resources,
  config_header
]

greeter_client_dependencies = [
  gdk,
  gtk,
  libsoup,
  dependency('libwnck-3.0'),
  webkit2gtk,
  javascriptcoregtk,
  gee,
  dependency('gdk-pixbuf-2.0'),
  json_glib,
  glib,
  gobject,
  lightdm,
  posix,
]
greeter_client_vala_options = greeter_vala_options

greeter_client_lib = static_library(
  'greeter-client',
  greeter_client_sources,
  dependencies: greeter_client_dependencies,
  vala_args: greeter_client_vala_options,
  c_args: greeter_c_options,
  include_directories: config_h_dir
)

greeter_client_dep = declare_dependency(
  link_with: greeter_client_lib,
  include_directories: include_directories('.')
)

# make the executable
greeter_bin_sources = files(
  'main.vala'
)
greeter_bin_sources += [
  greeter_resources,
  # config_header
]
greeter_bin_dependencies = [
  posix,
  gdk,
  greeter_client_dep,
  gtk,
  libsoup,
  gee,
  webkit2gtk,
]
greeter_bin = executable(meson.project_name(), greeter_bin_sources,
  vala_args: greeter_vala_options,
  dependencies: greeter_bin_dependencies,
  install: true,
  c_args: greeter_c_options,
  install_dir: '/opt/webkit2gtk-greeter'
)
