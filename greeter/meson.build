

greeter_c_options = [
  '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
  '-lm',
  '-include', 'config.h'
]

greeter_vala_options = [
  '--target-glib=@0@'.format(target_glib),
  '--enable-checking'
]

# Symbols for valac's preprocessor must be defined as compiler args,
# not in the code or in config.h
if reference_tracking
  greeter_vala_options += [ '--define=REF_TRACKING' ]
endif
if not poodle
  greeter_vala_options += [ '--define=DISABLE_POODLE' ]
endif

config_header = configure_file (
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

greeter_client_vala_sources = files(
  'widgets/Window.vala',
  'widgets/WebContainer.vala',
  'GreeterApplication.vala',
  'utils/ConfigReader.vala',
  'utils/GioUtil.vala'
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
  gio,
  posix,
]
greeter_client_vala_options = greeter_vala_options

greeter_client_lib = static_library(
  'luminos',
  greeter_client_sources,
  dependencies: greeter_client_dependencies,
  vala_args: greeter_client_vala_options,
  vala_gir: 'Luminos-1.0.gir',
  c_args: greeter_c_options,
  include_directories: config_h_dir
)

greeter_client_dep = declare_dependency(
  link_with: greeter_client_lib,
  include_directories: include_directories('.')
)

gir_path = join_paths(meson.build_root(), 'greeter', 'Luminos-1.0.gir')
if run_command('[', '-f', gir_path, ']').returncode() == 0
  message('generating typelib')
  g_ir_compiler = find_program('g-ir-compiler')
  custom_target('luminos typelib',
      command: [g_ir_compiler, '--output', '@OUTPUT@', '@INPUT@','--debug', '--verbose'],
      input: meson.current_build_dir() / 'Luminos-1.0.gir',
      output: 'Luminos-1.0.typelib',
      depends: greeter_client_lib,
      install: true,
      install_dir: get_option('libdir') / 'girepository-1.0')
endif

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
  c_args: greeter_c_options
)
