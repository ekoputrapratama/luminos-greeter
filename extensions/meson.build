
#Core extension
core_sources = [
  config_header,
  'core/jsapi.vala',
  'jsutils.vala',
  'core/DesktopFileReader.vala',

]

core_deps = [
  webkit2gtk_web_extension,
  javascriptcoregtk,
  json_glib,
  gobject,
  lightdm,
  gee,
]

core_extension = library('webkitgtk-greeter-core', core_sources,
  vala_args: ['--vapi=webkitgtk-greeter-core.vapi'],
  dependencies: core_deps,
  install: true,
  install_dir: '/opt/webkitgtk-greeter/extensions'
)

#Config Manager extension
config_manager_sources = [
  'config-manager/ClientConfigManager.vala',
  'config-manager/ConfigManager.vala',
  'jsutils.vala',
  config_header
]
config_manager_dependencies = [
  webkit2gtk_web_extension,
  javascriptcoregtk,
  json_glib,
  gee,
]
config_manager_extension = library('webkitgtk-greeter-config-manager', config_manager_sources,
  vala_args: ['--vapi=webkitgtk-greeter-config-manager.vapi'],
  dependencies: config_manager_dependencies,
  install: true,
  install_dir: ['/opt/webkitgtk-greeter/extensions', true, true]
)
