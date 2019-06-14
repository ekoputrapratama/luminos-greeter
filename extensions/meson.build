
utils_sources = [
  'jsutils.vala',
  'utils.vala'
]

utils_deependencies = [
  javascriptcoregtk,
  gio,
  gee
]

utils_lib = static_library(
  'utils',
  utils_sources,
  dependencies: utils_deependencies,
  vala_args: greeter_client_vala_options,
  c_args: greeter_c_options,
  include_directories: config_h_dir,
  install:true,
  install_dir: extensions_dir
)

utils_dep = declare_dependency(
  link_with: utils_lib,
  include_directories: include_directories('.')
)


#Core extension
core_sources = [
  'core/main.vala',
  'core/lightdm.vala',
  config_header
]

core_dependencies = [
  utils_dep,
  webkit2gtk_web_extension,
  javascriptcoregtk,
  json_glib,
  gobject,
  lightdm,
  gee,
  gio,
  glib
]

core_extension = library('luminos-greeter-core', core_sources,
  vala_args: ['--vapi=luminos-greeter-core.vapi'],
  dependencies: core_dependencies,
  install: true,
  install_dir: extensions_dir
)

#Config Manager extension
config_manager_sources = [
  'config-manager/main.vala',
  'config-manager/ConfigManager.vala',
  config_header
]
config_manager_dependencies = [
  utils_dep,
  webkit2gtk_web_extension,
  javascriptcoregtk,
  json_glib,
  gee,
  gio,
  glib
]
config_manager_extension = library('config-manager', config_manager_sources,
  vala_args: ['--vapi=config-manager.vapi'],
  dependencies: config_manager_dependencies,
  install: true,
  install_dir: extensions_dir
)

