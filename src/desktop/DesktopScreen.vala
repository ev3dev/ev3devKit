/*
 * ev3dev-tk - graphical toolkit for LEGO MINDSTORMS EV3
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* DesktopScreen.vala - Screen implementation for desktop (Gtk) */

using Curses;
using U8g;

namespace EV3devTk {
    public class DesktopScreen : EV3devTk.Screen {

        public DesktopScreen (FakeEV3LCDDevice lcd) {
            base (lcd.u8g_device);
            lcd.key_press_event.connect (on_key_press_event);
        }

        public override bool active { get { return true; } }

        bool on_key_press_event (Gdk.EventKey event) {
            uint key_code = 0;
            switch (event.keyval) {
            case Gdk.Key.Up:
                key_code = Key.UP;
                break;
            case Gdk.Key.Down:
                key_code = Key.DOWN;
                break;
            case Gdk.Key.Left:
                key_code = Key.LEFT;
                break;
            case Gdk.Key.Right:
                key_code = Key.RIGHT;
                break;
            case Gdk.Key.Return:
                key_code = Key.ENTER;
                break;
            case Gdk.Key.BackSpace:
                key_code = Key.BACKSPACE;
                break;
            default:
                return false;
            }
            queue_key_code (key_code);
            return true;
        }
    }
}
