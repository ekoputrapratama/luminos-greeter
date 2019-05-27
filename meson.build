project('io.github.webkit2gtk-greeter','c', 'vala',
  version: '1.0.0',
  meson_version: '>= 0.40.0',
)

am_cflags = [
  '-DWNCK_I_KNOW_THIS_IS_UNSTABLE',
  '-lm',
  '-DGETTEXT_PACKAGE=\"$(GETTEXT_PACKAGE)\"',
  '-DLOCALEDIR=\""$(localedir)"\"',
	'-DVERSION=\"$(VERSION)\"',
	'-DPKGDATADIR=\""$(pkgdatadir)"\"'
]

add_global_arguments(am_cflags, language: 'c')
add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')

i18n = import('i18n')
subdir('data')
subdir('greeter')
subdir('extensions')
meson.add_install_script('build-aux/postinstall.py')
