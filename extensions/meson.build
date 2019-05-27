extensions_sources = [
  'core/jsapi.vala',
  'jsutils.vala',
  
]
config_manager_sources = [
  'config-manager/ClientConfigManager.vala',
  'config-manager/ConfigManager.vala',
  'jsutils.vala'
]
extensions_deps = [
  dependency('webkit2gtk-web-extension-4.0'),
  dependency('javascriptcoregtk-4.0'),
  dependency('json-glib-1.0'),
  dependency('gobject-2.0'),
  dependency('liblightdm-gobject-1'),
  dependency('gee-0.8')
]

shared_library('webkit2gtk-greeter-core', extensions_sources,
  vala_args: ['--vapi=webkit2gtk-greeter.vapi'],
  dependencies: extensions_deps,
  install: true,
  install_dir: '/opt/webkit2gtk-greeter/extensions'
)
shared_library('webkit2gtk-greeter-config-manager', config_manager_sources,
  vala_args: ['--vapi=webkit2gtk-greeter.vapi'],
  dependencies: extensions_deps,
  install: true,
  install_dir: ['/opt/webkit2gtk-greeter/extensions',true,true]
)
