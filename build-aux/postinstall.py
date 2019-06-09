#!/usr/bin/env python3

from os import environ, path,symlink
from subprocess import call
from pprint import pprint

prefix = environ.get('MESON_INSTALL_PREFIX', '/usr/local')
datadir = path.join(prefix, 'share')
destdir = environ.get('DESTDIR', '')
homedir = environ.get("HOME", '')

# Package managers set this so we don't need to run
if not destdir:

    pprint('Updating icon cache...')
    call(['gtk-update-icon-cache', '-qtf', path.join(datadir, 'icons', 'hicolor')])

    pprint('Updating desktop database...')
    call(['update-desktop-database', '-q', path.join(datadir, 'applications')])

    pprint('Compiling GSettings schemas...')
    call(['glib-compile-schemas', path.join(datadir, 'glib-2.0', 'schemas')])
