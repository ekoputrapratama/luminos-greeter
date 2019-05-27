


gnome = import('gnome')

conf_data = configuration_data()
conf_data.set('CONF_DIR', join_paths(get_option('sysconfdir'), 'lightdm'))
conf_data.set('GETTEXT_PACKAGE', meson.project_name())

conf_data.set('VERSION', meson.project_version())
config_header = configure_file (
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

webkit2gtk_greeter_sources = [
  'widgets/Window.vala',
  'widgets/WebView.vala',
  'constants/WindowType.vala',
  'main.vala',
  config_header
]

webkit2gtk_greeter_sources += gnome.compile_resources('webkit2gtk-greeter-resources',
  'webkit2gtk-greeter.gresource.xml'
)
webkit2gtk_greeter_deps = [
  dependency('gdk-3.0', version: '>= 3.22'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libsoup-2.4'),
  dependency('libwnck-3.0'),
  dependency('webkit2gtk-4.0'),
  dependency('javascriptcoregtk-4.0'),
  dependency('gee-0.8'),
  dependency('gdk-pixbuf-2.0'),
  dependency('json-glib-1.0'),
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('liblightdm-gobject-1')
]



executable(meson.project_name(), webkit2gtk_greeter_sources,
  vala_args: ['--target-glib=2.2.5 --rdynamic'],
  dependencies: webkit2gtk_greeter_deps,
  install: true,
  install_dir: '/opt/webkit2gtk-greeter'
)
