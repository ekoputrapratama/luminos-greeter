cmd = run_command('sh', '-c', 'echo $HOME')
HOME_DIR = cmd.stdout().strip()
desktop_file = i18n.merge_file(
  input: 'luminos-greeter.desktop.in',
  output: 'luminos-greeter.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: '/usr/share/xgreeters'
)



desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

appstream_file = i18n.merge_file(
  input: 'luminos-greeter.appdata.xml.in',
  output: 'luminos-greeter.appdata.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata')
)


appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
  )
endif

install_data('io.github.luminos-greeter.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0/schemas')
)

install_subdir('_vendor', install_dir : '/usr/share/lightdm-webkit')
install_subdir('themes', install_dir : '/usr/share/lightdm-webkit')

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

