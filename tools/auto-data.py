'''
Copyright (C) 2026 Vladimir Romanov <rirusha@altlinux.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see
<https://www.gnu.org/licenses/gpl-3.0-standalone.html>.

SPDX-License-Identifier: GPL-3.0-or-later
'''

from pathlib import Path
import sys
import os
import subprocess

def compile_blueprint() -> None:
    subprocess.run([
        'blueprint-compiler',
        'batch-compile',
        '--gir-path', os.path.join(BUILD_ROOT, 'lib', 'src'),
        '--typelib-path', os.path.join(BUILD_ROOT, 'lib', 'src'),
        OUTPUT, CURRENT_SOURCE_DIR,
        *get_blp_files(False)
    ])

def get_blp_files(fix_path:bool=True) -> list[str]:
    return [str(f).removeprefix('../data/' if fix_path else '') for f in Path(UI_DIR).rglob('*.blp') if f.is_file()]

def get_assets_files() -> list[str]:
    return [str(f).removeprefix('../data/') for f in Path(ASSETS_DIR).rglob('*.svg') if f.is_file()]

def format_blp_files() -> str:
    files = []
    for f in get_blp_files():
        files.append(f'<file preprocess="xml-stripblanks">{f.replace('.blp', '.ui')}</file>')
    return '\n    '.join(files)

def format_assets_files() -> str:
    files = []
    for f in get_assets_files():
        files.append(f'<file alias="{os.path.basename(f)}">{f}</file>')
    return '\n    '.join(files)

def create_gresources() -> None:
    with open(RESOURCE_PATH, 'r') as rf:
        with open(RESOURCE_PATH_O, 'w') as rfo:
            data = rf.read()
            data = data.replace('@ICONS_DATA@', format_assets_files())
            data = data.replace('@UI_RESOURCES@', format_blp_files())
            data = data.replace('@APP_ID_RELEVANT@', METAINFO_NAME)
            rfo.write(data)


OUTPUT = sys.argv[1]
SOURCE_ROOT = sys.argv[2]
BUILD_ROOT = sys.argv[3]
CURRENT_SOURCE_DIR = sys.argv[4]
METAINFO_NAME = sys.argv[5]

UI_DIR = os.path.join(SOURCE_ROOT, 'data', 'ui')
ASSETS_DIR = os.path.join(SOURCE_ROOT, 'data', 'assets')

RESOURCE_PATH = os.path.join(SOURCE_ROOT, 'data', 'gresource.xml.in')
RESOURCE_PATH_O = os.path.join(BUILD_ROOT, 'data', 'gresource.xml')

compile_blueprint()
create_gresources()
