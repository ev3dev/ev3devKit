#!/usr/bin/env python3

# ev3devKit - ev3dev toolkit for LEGO MINDSTORMS EV3
#
# Copyright 2015,2017 David Lechner <david@lechnology.com>
#           2015 Stefan Sauer <ensonic@google.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.

# ui_demo.py - main function for running UI demo

import gi

gi.require_version('Ev3devKit', '0.5')
from gi.repository import Ev3devKit

from ui_demo_window import UiDemoWindow


def do_activate(app):
    demo_window = UiDemoWindow()
    demo_window.connect('quit', lambda _: app.quit())
    demo_window.show()


def main():
    app = Ev3devKit.ConsoleApp.new()

    activate_id = app.connect('activate', do_activate)

    app.run()
    app.disconnect(activate_id)

if __name__ == "__main__":
    main()
