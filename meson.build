project('luminos-greeter','c', 'vala',
  version: '1.0.0',
  meson_version: '>= 0.40.0',
)

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

i18n = import('i18n')
gnome = import('gnome')

reference_tracking = get_option('ref_tracking')
poodle = get_option('poodle')
valac = meson.get_compiler('vala')

application_id = 'io.github.luminos-greeter'
config_h_dir = include_directories('.')
greeter_prefix = get_option('prefix')
libdir = join_paths(greeter_prefix, get_option('libdir'))
extensions_dir = join_paths(libdir, 'luminos', 'extensions')
datadir = join_paths(greeter_prefix, get_option('datadir'), 'luminos')

target_gtk = '3.24.7'
target_glib = '2.2.5'
target_webkit = '2.20'

# Primary deps
glib = dependency('glib-2.0', version: '>=' + target_glib)
gtk = dependency('gtk+-3.0', version: '>=' + target_gtk)
webkit2gtk = dependency('webkit2gtk-4.0', version: '>=' + target_webkit)
lightdm = dependency('liblightdm-gobject-1')

# Secondary deps
gdk = dependency('gdk-3.0', version: '>=' + target_gtk)
gee = dependency('gee-0.8', version: '>= 0.8.5')
gio = dependency('gio-2.0', version: '>=' + target_glib)
javascriptcoregtk = dependency('javascriptcoregtk-4.0', version: '>=' + target_webkit)
json_glib = dependency('json-glib-1.0', version: '>= 1.0')
webkit2gtk_web_extension = dependency('webkit2gtk-web-extension-4.0', version: '>=' + target_webkit)
libsoup = dependency('libsoup-2.4', version: '>= 2.48')
libwnck = dependency('libwnck-3.0')
gobject = dependency('gobject-2.0')
posix = valac.find_library('posix')


conf_data = configuration_data()
conf_data.set_quoted('CONF_DIR', join_paths('/',get_option('sysconfdir'), 'lightdm'))
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('G_LOG_DOMAIN', meson.project_name())
conf_data.set_quoted('PACKAGE_NAME', meson.project_name())
conf_data.set_quoted('APPLICATION_ID', application_id)
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('DATA_DIR', datadir)
conf_data.set_quoted('THEMES_DIR', join_paths(datadir, 'themes'))
conf_data.set_quoted('BACKGROUNDS_DIR', join_paths(datadir, 'backgrounds'))
conf_data.set_quoted('VENDOR_DIR', join_paths(datadir, '_vendor'))
conf_data.set_quoted('_EXTENSIONS_DIR', extensions_dir)
conf_data.set_quoted('_INSTALL_PREFIX', greeter_prefix)
conf_data.set_quoted('_BUILD_ROOT_DIR', meson.build_root())
conf_data.set_quoted('_SOURCE_ROOT_DIR', meson.source_root())
conf_data.set_quoted('VERSION', meson.project_version())

conf_data.set_quoted('PACKAGE_STRING', '@0@-@1@'.format(meson.project_name(), meson.project_version()))
conf_data.set_quoted('PACKAGE_VERSION', meson.project_version())
configure_file(output: 'config.h', configuration: conf_data)

subdir('resources')
subdir('data')
subdir('greeter')
subdir('extensions')
subdir('tests')

meson.add_install_script('build-aux/postinstall.py')
